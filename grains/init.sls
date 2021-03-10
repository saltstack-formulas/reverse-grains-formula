#!py
import yaml

class GrainMaker:
  """Generates the /etc/salt/grains file based on pillar data.
  Example pillar:
  grains:
    grain1:
      grainvalue1:
        - G@id:host1
        - G@id:host2
      grainvalue2:
        - G@id:host3
    grain2:
      grainvalue1:
        - G@id:host1
        - G@id:host2

  Grains are assigned to each minion via compound matchers.
  """
  def __init__(self):
    self._grains = {}

  def _createGrainsYaml(self):
    # Outputs the final yaml for /etc/salt/grains
    return yaml.dump(self._grains, default_flow_style=False)

  def _matchValueToMinion(self, matchList):
    # Checks that the matches for each grain value apply to this minion
    matchList = matchList or []
    return any(__salt__["match.compound"](match) for match in matchList)

  def _addToGrains(self, grain, grainKey, value):
    # Collects the grains into a dictionary
    if self._matchValueToMinion(grain[grainKey][value]):
      valueList = self._grains.get(grainKey, [])
      valueList.append(value)

      self._grains[grainKey] = valueList

  def _parseGrainValues(self, grain):
    # Parses individual grains and their values passed from the pillar
    grainKey = next(iter(grain.keys()))
    if grain[grainKey]:
      for value in grain[grainKey]:
        self._addToGrains(grain, grainKey, value)

      # If there is only one value for a grain, make sure it is a string
      # and not a single item list. This is import for the yaml to be
      # properly formatted.
      if len(self._grains.get(grainKey, [])) == 1:
        self._grains[grainKey] = self._grains[grainKey][0]

  def buildGrains(self, grains):
    """Starts the grain building process."""
    for grain in grains:
      self._parseGrainValues({grain: grains[grain]})

    return self._createGrainsYaml()

def run():
  maker=GrainMaker()
  grainsYaml = maker.buildGrains(__pillar__["grains"])

  return {'/etc/salt/grains':
           {'file.managed': [
             {'contents': grainsYaml},
             {'user': 'root'},
             {'group': 'root'},
             {'mode': '644'}]
           }
         }

from pathlib import Path
import yaml


config_file = Path(__file__).parent.parent.parent / Path('config.yaml')

with config_file.open() as f:
    config = yaml.load(f)

# envoy_schema_generator/cli.py
import click
from .version_resolver import resolve_commit_shas
from .github_utils import get_latest_release

@click.group()
def cli():
    pass

@cli.command()
@click.option('--envoy-version', required=True, help='Envoy version to generate schema for')
def generate_schema(envoy_version):
    click.echo(f"Generating schema for Envoy version {envoy_version}")
    shas = resolve_commit_shas(envoy_version)
    for repo, sha in shas.items():
        click.echo(f"{repo}: {sha}")
    # Add logic here to update your submodules and generate the schema

@cli.command()
def check_new_release():
    latest_release = get_latest_release('envoyproxy/envoy')
    if latest_release:
        click.echo(f"Latest Envoy release: {latest_release}")
        # Add logic here to trigger schema generation if it's a new release
    else:
        click.echo("Failed to fetch latest Envoy release")

@cli.command()
@click.option('--num-releases', default=5, help='Number of recent Envoy releases to generate schema for')
def seed_releases(num_releases):
    # Logic to fetch the last N releases and generate schema for each
    # This would involve multiple API calls to GitHub
    pass
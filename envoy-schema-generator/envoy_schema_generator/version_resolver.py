# envoy_schema_generator/version_resolver.py

from .github_utils import get_commit_sha_for_tag

REPOS = {
    'envoy': 'envoyproxy/envoy',
    'xds': 'cncf/xds',
    'protoc-gen-validate': 'envoyproxy/protoc-gen-validate',
    'googleapis': 'googleapis/googleapis',
    'opencensus-proto': 'census-instrumentation/opencensus-proto',
    'opentelemetry-proto': 'open-telemetry/opentelemetry-proto',
    'client_model': 'prometheus/client_model'
}

def resolve_commit_shas(envoy_version):
    shas = {}
    for repo_name, repo_path in REPOS.items():
        if repo_name == 'envoy':
            tag = envoy_version
        else:
            # Logic to determine the correct tag for other repos
            # This might require additional API calls or logic
            tag = 'main'  # Placeholder

        sha = get_commit_sha_for_tag(repo_path, tag)
        shas[repo_name] = sha

    return shas
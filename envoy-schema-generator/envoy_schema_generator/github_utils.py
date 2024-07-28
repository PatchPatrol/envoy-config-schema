# envoy_schema_generator/github_utils.py

import requests

def get_latest_release(repo):
    url = f"https://api.github.com/repos/{repo}/releases/latest"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()['tag_name']
    return None

def get_commit_sha_for_tag(repo, tag):
    url = f"https://api.github.com/repos/{repo}/git/refs/tags/{tag}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()['object']['sha']
    return None
# shellcheck shell=bash

function main {
  source __argProjects__/template projects_markdowns

  : && rm -rf content/projects/* \
    && rm -rf data/projects/* \
    && for project in "${!projects_markdowns[@]}"; do
      : && echo --- > "content/projects/${project}.md" \
        && echo "project: ${project}" >> "content/projects/${project}.md" \
        && echo --- >> "content/projects/${project}.md" \
        && copy "${projects_markdowns[$project]}" "data/projects/${project}.json" \
        || return 1
    done
}

main "${@}"

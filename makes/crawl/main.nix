{ inputs
, makeTemplate
, makeScript
, toBashMap
, toFileJson
, ...
}:
let
  prod = true;

  projects = builtins.mapAttrs
    (project: projectMeta: toFileJson project {
      title = project;
      meta = projectMeta.meta;
      versions = builtins.mapAttrs
        (version: versionMeta: {
          pythonVersions = builtins.mapAttrs
            (pythonVersion: pythonVersionMeta: {
              closure = pythonVersionMeta.closure;
            })
            (versionMeta.pythonVersions);
        })
        (projectMeta.versions);
    })
    (if prod
    then inputs.pythonOnNix.projectsMeta
    else {
      aioextensions = inputs.pythonOnNix.projectsMeta.aioextensions;
      django = inputs.pythonOnNix.projectsMeta.django;
    });
in
makeScript {
  name = "crawl";
  entrypoint = ./entrypoint.sh;
  replace = {
    __argProjects__ = toBashMap projects;
  };
}

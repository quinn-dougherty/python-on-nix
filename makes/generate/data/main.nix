{ attrsMapToList
, inputs
, makeTemplate
, makeScript
, toBashMap
, toFileJson
, ...
}:
let
  prod = false;

  toSemverList = attrs:
    builtins.sort
      (a: b:
        if a.name == "latest" || a.name == "pythonLatest"
        then true
        else if b.name == "latest" || b.name == "pythonLatest"
        then false
        else (builtins.compareVersions a.name b.name) > 0)
      (attrsMapToList (name: data: { inherit data name; }) attrs);

  projects = builtins.mapAttrs
    (project: projectMeta: toFileJson project {
      title = project;
      meta = projectMeta.meta;
      setup =
        if builtins.pathExists projectMeta.setupPath
        then builtins.readFile projectMeta.setupPath
        else "{ }";
      tests = builtins.readFile projectMeta.testPath;
      versions = toSemverList (builtins.mapAttrs
        (version: versionMeta: {
          pythonVersions = toSemverList (
            builtins.removeAttrs
              (builtins.mapAttrs
                (pythonVersion: pythonVersionMeta: {
                  demo = {
                    nixStable = ''
                      let
                        pythonOnNix = import (builtins.fetchGit {
                          ref = "${inputs.pythonOnNixRef}";
                          rev = "${inputs.pythonOnNixRev}";
                          url = "${inputs.pythonOnNixUrl}";
                        });
                      in
                      pythonOnNix.${pythonVersion}Env {
                        name = "example";
                        projects = {
                          "${project}" = "${version}";
                        };
                      };
                    '';
                    nixUnstable = ''
                    '';
                  };
                  inherit (pythonVersionMeta) closure;
                })
                (versionMeta.pythonVersions))
              [ "pythonLatest" ]
          );
        })
        (projectMeta.versions));
    })
    (if prod
    then inputs.pythonOnNix.projectsMeta
    else {
      botocore = inputs.pythonOnNix.projectsMeta.botocore;
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

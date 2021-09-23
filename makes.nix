{ inputs
, ...
}:
{
  inputs = {
    pythonOnNixSrc = builtins.fetchGit {
      ref = "main";
      url = "https://github.com/kamadorueda/python-on-nix";
    };
    pythonOnNix = import inputs.pythonOnNixSrc;
  };
}

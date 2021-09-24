{ inputs
, ...
}:
{
  inputs = {
    pythonOnNixRef = "main";
    pythonOnNixRev = "910d3f6554acd4a4ef0425ebccd31104dccb283c";
    pythonOnNixUrl = "https://github.com/kamadorueda/python-on-nix";
    pythonOnNix = import (builtins.fetchGit {
      ref = inputs.pythonOnNixRef;
      rev = inputs.pythonOnNixRev;
      url = inputs.pythonOnNixUrl;
    });
  };
}

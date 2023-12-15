{
  config
  , lib
  , ...
}:
rec {
  # https://nixos.wiki/wiki/CCache
  programs.ccache = 
  {
    enable = true;
    cacheDir = "/var/cache/ccache";
  };

  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
}

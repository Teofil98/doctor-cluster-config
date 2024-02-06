{ buildLinux, fetchFromGitHub, ... }@args:
let

  svsm_preview_hv_1 = {
    owner = "AMDESE";
    repo = "linux";
    rev = "e69def60bfa53acef2a5ebd8c85d8d544eb2cbbe"; # branch svsm-preview-hv
    sha256 = "sha256-DT3Ych/3BoeqxYFn2F8PajmmPufrN619zZa6X5WUHvo=";
    version = "5.14";
    modDirVersionArg = "5.14.0-rc2";
    extraPatches = [
      {
        # for some reaon, the BTF build fails for 5.14 svsm kernel
        # so just disable it
        name = "disable BTF";
        patch = null;
        extraConfig = ''
          DEBUG_INFO_BTF n
        '';
      }
    ];
  };

  svsm_preview_hv_2 = {
    owner = "AMDESE";
    repo = "linux";
    rev = "4c33a31c6e1524f1b90834aaaea250a085f72dac"; # branch svsm-preview-hv-2
    sha256 = "sha256-eNSQ1monsTvZuI0NnJQx9rqUD8zc3puCqtCS5eYDon0=";
    version = "6.1";
    modDirVersionArg = "6.1.0-rc4";
    extraPatches = [ ];
  };
  svsm_preview_hv_v4 = {
    owner = "AMDESE";
    repo = "linux";
    rev = "557bec5818023359f85d4f55273a0ddf2323556a"; # branch svsm-preview-hv-4
    sha256 = "sha256-F8aalopWWt1aSKojmeln57IoO93b/x5p68oreNBkHqc=";
    version = "6.7";
    modDirVersionArg = "6.7.0-rc6-next-20231222";
    extraPatches = [
	      {
      
        name = "zfs export fix";
        patch = ./bug_func.patch;
        extraConfig = ''
        '';
              }
              {
        name = "nfs fix";
        patch = ./nfs.patch;
        extraConfig = ''
        '';
             }

                 ];
  };


#  coconut_svsm = {
#    owner = "coconut-svsm";
#    repo = "linux";
#    rev = "e1335c6f029281db280945e084ec2d079934e744"; # branch svsm
#    sha256 = "sha256-Q/gTKUvWE/9wGExzbgxJPjfz2g2JtKPAp93jcbl3rBw=";
#    version = "6.5";
#    modDirVersionArg = "6.5.0";
#    extraPatches = [ ];
#  };
  # snp_kernel = svsm_preview_hv_1;
  #snp_kernel = coconut_svsm;
   snp_kernel = svsm_preview_hv_v4;
in
with snp_kernel;
buildLinux (args // rec {
  inherit version;
  modDirVersion =
    if (snp_kernel.modDirVersionArg == null) then
      builtins.replaceStrings [ "-" ] [ ".0-" ] version
    else
      modDirVersionArg;
  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };

  kernelPatches = [
    {
      name = "amd_sme-config";
      patch = null;
      extraConfig = ''
        AMD_MEM_ENCRYPT y
        CRYPTO_DEV_CCP y
        CRYPTO_DEV_CCP_DD y
        CRYPTO_DEV_SP_PSP y
        KVM_AMD_SEV y
        MEMORY_FAILURE y
        EXPERT y
      '';
    }
  ] ++ extraPatches;
  extraMeta.branch = version;
  ignoreConfigErrors = true;
} // (args.argsOverride or { }))

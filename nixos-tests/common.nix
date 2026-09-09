let
  # Shared nix settings for all test VMs
  nixSettings = {
    settings.substituters = [ ];
  };
in

{
  serverConfig =
    { pkgs, ... }:
    {
      imports = [
        ../nixos-modules/web-app.nix
        ../nixos-modules/queue-runner-module.nix
        ../nixos-modules/ad-hoc-module.nix
      ];

      services.hydra-dev.enable = true;
      services.hydra-dev.hydraURL = "http://hydra.example.org";
      services.hydra-dev.notificationSender = "admin@hydra.example.org";

      services.hydra-queue-runner-dev.enable = true;
      services.hydra-queue-runner-dev.grpc.address = "[::]";

      services.hydra-ad-hoc-dev.enable = true;

      systemd.services.hydra-send-stats.enable = false;

      services.postgresql.enable = true;

      time.timeZone = "UTC";

      nix = nixSettings // {
        package = pkgs.nixVersions.nix_2_35;
        extraOptions = ''
          allowed-uris = https://github.com/
        '';
      };

      networking.firewall.allowedTCPPorts = [ 50051 ];

      virtualisation.memorySize = 2048;
      virtualisation.writableStore = true;

      environment.systemPackages = [
        pkgs.perlPackages.LWP
        pkgs.perlPackages.JSON
      ];
    };

  builderConfig =
    { pkgs, ... }:
    {
      imports = [
        ../nixos-modules/builder-module.nix
      ];

      services.hydra-queue-builder-dev.enable = true;
      services.hydra-queue-builder-dev.queueRunnerAddr = "http://server:50051";

      virtualisation.memorySize = 2048;
      virtualisation.writableStore = true;

      nix = nixSettings // {
        package = pkgs.nixVersions.nix_2_35;
      };
    };
}

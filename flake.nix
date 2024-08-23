{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
	url = "github:nix-community/home-manager";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
	  fzf
	  helix
	  raycast
	  ripgrep
	  zoxide
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # managed in home.nix
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      
      nixpkgs.config = {
        # Disable if you don't want unfree packages
        allowUnfree = true;
      };

      users.users.nick = {
          name = "nick";
          home = "/Users/nick";
      };
      
      home-manager.backupFileExtension = "backup";
      nix.configureBuildUsers = true;
      nix.useDaemon = true;

      # Manage some MacOS settings
      system.defaults = {
        dock = {
	  autohide = true;
	  autohide-delay = 0.01;
	  tilesize = 48;
	  orientation = "left";
	  minimize-to-application = true;
	  showhidden = true;
	  show-recents = false;
          mru-spaces = false;
	  # persistent-others = [ "~" "Users/nick/Downloads" ];
	  # corners hot action
	  wvous-tl-corner = 2;
	  wvous-tr-corner = 10;
	  wvous-br-corner = 4;
	  wvous-bl-corner = 3;
	};
        finder = {
	  AppleShowAllExtensions = true;
          FXPreferredViewStyle = "clmv";
          FXDefaultSearchScope = "SCcf";
	  ShowPathbar = true;
	  ShowStatusBar = true;
	};
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };
      security.pam.enableSudoTouchIdAuth = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#virtnix
    darwinConfigurations."virtnix" = nix-darwin.lib.darwinSystem {
      modules = [ 
	configuration
	home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nick = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
	];
    };
    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."virtnix".pkgs;
  };
}

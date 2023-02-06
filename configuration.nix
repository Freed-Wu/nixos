# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # basic {{{ #
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.tmpOnTmpfs = true;
  # https://discourse.nixos.org/t/i915-driver-has-bug-for-iris-xe-graphics/25006
  boot.kernelParams = [ "i915.enable_psr=0" ];

  nix.settings.substituters = [ "https://mirrors.bfsu.edu.cn/nix-channels/store" ];
  nixpkgs.config = { allowUnfree = true; };
  hardware.enableAllFirmware = true;

  security.sudo.wheelNeedsPassword = false;

  networking.hostName = "laptop";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  time.timeZone = "Asia/Shanghai";

  console = {
    font = "latarcyrheb-sun32";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users.wzy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "input" ];
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
  # }}} basic #

  # GUI {{{ #
  # Select internationalisation properties.
  i18n.inputMethod = {
    enabled = "fcitx5";
  };
  i18n.inputMethod.fcitx5.enableRimeData = true;
  i18n.inputMethod.fcitx5.addons = [ pkgs.fcitx5-rime ];

  fonts.enableDefaultFonts = true;
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    wqy_zenhei
    wqy_microhei
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.libinput.enable = true;
  # Configure keymap in X11
  services.xserver.desktopManager.lxqt.enable = true;
  services.xserver.displayManager.defaultSession = "lxqt";
  services.xserver.displayManager.lightdm.greeters.slick.font.name = "Ubuntu 24";
  # https://github.com/Freed-Wu/my-x11-keymaps
  services.xserver.xkbDir = "/usr/share/X11/xkb";

  services.picom = {
    enable = true;
    fade = true;
    inactiveOpacity = 0.95;
    settings = {
      blur = {
        kern = "3x3box";
        background-exclude = [
          "class_g ?= 'zoom'"
          "window_type = 'dock'"
          "class_g ?= 'wemeetapp'"
          "name = 'rect-overlay'"
          "window_type = 'desktop'"
          "_GTK_FRAME_EXTENTS@:c"
        ];
      };
    };
    shadow = true;
    shadowExclude = [
      "name = 'cpt_frame_xcb_window'"
      "class_g ?= 'zoom'"
      "class_g ?= 'wemeetapp'"
      "name = 'rect-overlay'"
      "name = 'Notification'"
      "class_g = 'Conky'"
      "class_g ?= 'Notify-osd'"
      "class_g = 'Cairo-clock'"
      "_GTK_FRAME_EXTENTS@:c"
    ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  environment.lxqt.excludePackages = [
    pkgs.lxqt.qterminal
  ];
  # }}} GUI #

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      # python {{{ #
      (
        python3.withPackages (
          p: with p; [
            gdown
            isort
            pudb
            ptpython
            rich
            colorama
            beautifulsoup4
            lxml
            pandas
            pre-commit
            pytest
            pip
            dbus-python
            jedi-language-server
            tensorboard
            torchWithoutCuda
            torchvision
            torchmetrics
            sphinx
            py-cpuinfo
          ]
        )
      )
      # trash-cli need to create some symlinks
      trash-cli
      asciinema
      pdd
      grc
      hyfetch
      # }}} python #
      # perl {{{ #
      (
        perl.withPackages (
          p: with p; [
            PerlTidy
          ]
        )
      )
      exiftool
      parallel
      # }}} perl #
      # ruby {{{ #
      (
        ruby.withPackages (
          p: with p; [
            jekyll
          ]
        )
      )
      # }}} ruby #
      # nodejs {{{ #
      nodejs
      nodePackages.gitmoji-cli
      # }}} nodejs #
      # rust {{{ #
      firefox
      wezterm
      onefetch
      mdcat
      exa
      fd
      vivid
      delta
      bat
      ripgrep
      bottom
      hexyl
      hyperfine
      nixpkgs-fmt
      texlab
      # }}} rust #
      # go {{{ #
      fzf
      scc
      direnv
      gh
      wakatime
      gdu
      docker
      shfmt
      git-lfs
      cog
      rime-cli
      # }}} go #
      # shell {{{ #
      wgetpaste
      pass
      hr
      lesspipe
      bash-completion
      zsh-completions
      zsh-powerlevel10k
      # }}} shell #
      # haskell {{{ #
      shellcheck
      pandoc
      # }}} haskell #
      # f# {{{ #
      marksman
      # }}} f# #
      # java {{{ #
      pdftk
      # }}} java #
      # c {{{ #
      hello
      lsb-release
      xdotool
      autoconf
      automake
      gnumake
      gcc
      gdb
      cgdb
      neomutt
      wget
      curl
      git
      tmux
      file
      dos2unix
      dmidecode
      android-tools
      scrcpy
      pciutils
      usbutils
      texlive.combined.scheme-full
      linux-firmware
      p7zip
      w3m
      elinks
      jq
      acpi
      zathura
      ffmpeg
      x264
      moreutils
      bc
      num-utils
      xsel
      espeak-classic
      # }}} c #
      # c++ {{{ #
      cmake
      x265
      aria2
      lftp
      libsForQt5.yuview
      luaformatter
      chafa
      patchelf
      ansifilter
      libreoffice-fresh
      # }}} c++ #
    ];

  # program {{{ #
  services.dockerRegistry.enable = true;
  services.dockerRegistry.enableDelete = true;
  services.dockerRegistry.enableGarbageCollect = true;
  services.v2raya.enable = true;
  # https://github.com/NixOS/nixpkgs/issues/213989
  services.snapper.configs = {
    root = {
      subvolume = "/";
      extraConfig = ''
        ALLOW_GROUPS="wheel"
        TIMELINE_CREATE=yes
        TIMELINE_CLEANUP=yes
      '';
    };
  };

  programs.proxychains.enable = true;
  programs.proxychains.proxies = {
    myproxy = {
      type = "socks5";
      host = "127.0.0.1";
      port = 1080;
    };
  };
  programs.less.envVariables = {
    LESS = "--mouse --chop-long-lines -I -R -M";
  };
  programs.tmux.terminal = "screen-256color";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.zsh.enable = true;
  programs.zsh.enableBashCompletion = true;
  programs.zsh.enableGlobalCompInit = true;
  programs.zsh.autosuggestions.async = true;
  programs.zsh.setOptions = [ "HIST_IGNORE_DUPS" "SHARE_HISTORY" "HIST_FCNTL_LOCK" "emacs" ];
  programs.zsh.histSize = 20000;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.vimAlias = true;
  programs.neovim.viAlias = true;
  programs.neovim.withNodeJs = true;
  programs.neovim.configure = {
    customRC = ''
      if filereadable(stdpath('config') . '/init.vim')
        execute 'source' stdpath('config') . '/init.vim'
      endif
    '';
  };
  # }}} program #
}
# ex: foldmethod=marker

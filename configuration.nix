# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

rec {
  # basic {{{ #
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "@wheel" ];
  nix.settings.substituters = [ "https://mirrors.bfsu.edu.cn/nix-channels/store" ];
  nix.settings.use-xdg-base-directories = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.tmp.useTmpfs = true;

  nixpkgs.config = import ~/.config/nixpkgs/config.nix;
  hardware.enableAllFirmware = true;
  hardware.sensor.iio.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    # intel-ocl
    intel-compute-runtime
  ];

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

  console.font = "latarcyrheb-sun32";
  console.useXkbConfig = true; # use xkbOptions in tty.

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users.wzy.isNormalUser = true;
  users.users.wzy.description = "Wu Zhenyu";
  users.users.wzy.extraGroups = [ "wheel" "networkmanager" "input" "docker" "dialout" ];

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
  i18n.inputMethod.enabled =
    if
      services.xserver.displayManager.defaultSession == "gnome" then
      "ibus"
    else
      "fcitx5";
  i18n.inputMethod.fcitx5.addons = [ pkgs.fcitx5-rime ];
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [ rime ];

  fonts.fontDir.enable = true;
  fonts.enableDefaultPackages = true;
  fonts.packages = with pkgs; [
    wqy_zenhei
    wqy_microhei
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.libinput.enable = true;
  # Configure keymap in X11
  services.xserver.displayManager.defaultSession = "gnome";
  services.xserver.desktopManager.gnome.enable = services.xserver.displayManager.defaultSession == "gnome";
  services.xserver.displayManager.gdm.enable = services.xserver.displayManager.defaultSession == "gnome";

  services.xserver.desktopManager.plasma5.enable = services.xserver.displayManager.defaultSession == "plasma";
  services.xserver.displayManager.sddm.enable = services.xserver.displayManager.defaultSession == "plasma";

  services.xserver.desktopManager.lxqt.enable = services.xserver.displayManager.defaultSession == "lxqt";

  services.xserver.desktopManager.xfce.enable = services.xserver.displayManager.defaultSession == "xfce";

  services.xserver.displayManager.lightdm.greeters.slick.font.name = "Ubuntu 24";

  # https://discourse.nixos.org/t/how-to-use-fingerprint-unlocking-how-to-set-up-fprintd-english/21901/2
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
  services.picom.enable = services.xserver.displayManager.defaultSession != "gnome" && services.xserver.displayManager.defaultSession != "plasma";
  services.picom.fade = true;
  services.picom.inactiveOpacity = 0.95;
  services.picom.settings = {
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

  services.xserver.excludePackages = [
    pkgs.xterm
  ];

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  environment.lxqt.excludePackages = [
    pkgs.lxqt.qterminal
  ];
  environment.xfce.excludePackages = [
    pkgs.xfce.xfce4-terminal
  ];
  environment.gnome.excludePackages = [
    pkgs.gnome-console
    pkgs.gedit
    pkgs.epiphany
    pkgs.evince
  ];
  environment.plasma5.excludePackages = [
    pkgs.plasma5Packages.konsole
    pkgs.plasma5Packages.kate
    pkgs.plasma5Packages.konqueror
    pkgs.plasma5Packages.okular
  ];
  # }}} GUI #

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      man-pages
      man-pages-posix
      glibcInfo
      # python {{{ #
      (
        python3.withPackages (
          p: with p; [
            # color
            rich
            colorama
            # tool
            # https://github.com/petronny/pinyin-completion
            pypinyin
            # https://translate-shell.readthedocs.io/en/latest/resources/requirements.html#repl
            jedi
            gdown
            # PKGBUILD
            nvchecker
            # develop
            pip
            build
            ruff-lsp
            # debug
            ptpython
            pudb
            pytest
            pytest-pudb
            # data science
            beautifulsoup4
            lxml
            pandas
            # deep learning
            openai
            wandb
            tensorboard
            torchWithoutCuda
            torchvision
            torchmetrics
            # misc
            nur.repos.Freed-Wu.mulimgviewer
            nur.repos.Freed-Wu.translate-shell
            nur.repos.Freed-Wu.repl-python-wakatime
            # TODO: https://github.com/NixOS/nixpkgs/issues/263630
            # nur.repos.Freed-Wu.autotools-language-server
            # nur.repos.Freed-Wu.bitbake-language-server
            # nur.repos.Freed-Wu.expect-language-server
            # nur.repos.Freed-Wu.mutt-language-server
            # TODO: https://github.com/NixOS/nixpkgs/issues/241691
            # nur.repos.Freed-Wu.requirements-language-server
            # nur.repos.Freed-Wu.sublime-syntax-language-server
            # nur.repos.Freed-Wu.termux-language-server
            # nur.repos.Freed-Wu.tmux-language-server
            # nur.repos.Freed-Wu.xilinx-language-server
            # nur.repos.Freed-Wu.zathura-language-server
          ]
        )
      )
      trash-cli
      visidata
      asciinema
      asciinema-agg
      pdd
      # http://github.com/zpm-zsh/colorize
      grc
      hyfetch
      pre-commit
      doq
      cmake-format
      cmake-language-server
      # }}} python #
      # perl {{{ #
      (
        perl.withPackages (
          p: with p; [
            PerlTidy
            po4a
            PerlLanguageServer
          ]
        )
      )
      rename
      exiftool
      parallel
      # }}} perl #
      # ruby {{{ #
      (
        ruby.withPackages (
          p: with p; [
            solargraph
            rubocop
            pry
          ]
        )
      )
      # }}} ruby #
      # nodejs {{{ #
      nodejs
      nodePackages.yarn
      nodePackages.gitmoji-cli
      nodePackages.pyright
      dot-language-server
      # TODO: https://github.com/NixOS/nixpkgs/pull/245016
      # nodePackages.gitmoji-chanagelog
      # }}} nodejs #
      # lua {{{ #
      lua-language-server
      (
        lua.withPackages (
          p: with p; [
            # pre-commit needs it
            luarocks
            luacheck
          ]
        )
      )
      # }}} lua #
      # tcl {{{ #
      nagelfar
      # }}} tcl #
      # rust {{{ #
      taplo
      manix
      nix-index-database
      tree-sitter
      nixpkgs-fmt
      cargo
      firefox
      # https://github.com/wez/wezterm/issues/792
      # https://github.com/wez/wezterm/issues/3766
      # https://github.com/alacritty/alacritty/issues/4070
      alacritty
      onefetch
      mdcat
      eza
      fd
      vivid
      delta
      bat
      ripgrep
      ripgrep-all
      bottom
      hexyl
      hyperfine
      texlab
      typst
      # FIXME: https://github.com/NixOS/nixpkgs/issues/273835
      # typst-lsp
      asm-lsp
      # }}} rust #
      # go {{{ #
      go
      fq
      actionlint
      fzf
      scc
      direnv
      gh
      wakatime
      gdu
      shfmt
      git-lfs
      cog
      nix-build-uncached
      # }}} go #
      # shell {{{ #
      emojify
      wgetpaste
      pass
      hr
      has
      lesspipe
      bats
      bats.libraries.bats-support
      bats.libraries.bats-assert
      bash-completion
      zsh-completions
      zsh-powerlevel10k
      nur.repos.Freed-Wu.manpager
      nur.repos.Freed-Wu.undollar
      nur.repos.Freed-Wu.bash-prompt
      # }}} shell #
      # haskell {{{ #
      haskellPackages.nvfetcher
      haskellPackages.ShellCheck
      haskellPackages.pandoc-cli
      haskellPackages.cachix
      # }}} haskell #
      # f# {{{ #
      marksman
      # }}} f# #
      # java {{{ #
      jdk
      plantuml
      pdftk
      ltex-ls
      # }}} java #
      # c {{{ #
      gimp
      poppler_utils
      bear
      minicom
      socat
      nmap
      glxinfo
      clinfo
      dpkg
      rpm
      pacman
      fakeroot
      libarchive
      fontconfig
      imagemagick
      sqlite
      hello
      lsb-release
      gtk3
      glib
      xdotool
      autoconf
      automake
      pkg-config
      readline
      gnumake
      gcc
      gdb
      rr
      valgrind
      nur.repos.Freed-Wu.gdb-prompt
      cgdb
      neomutt
      wget
      curl
      git
      subversion
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
      (p7zip.override { enableUnfree = true; })
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
      espeak-classic
      gettext
      progress
      ethtool
      pstree
      # }}} c #
      # c++ {{{ #
      openai-triton-llvm
      libreoffice-fresh
      watchman
      cppcheck
      nixd
      qq
      clang-tools
      gtest.dev
      cmake
      ninja
      cling
      x265
      aria2
      lftp
      yuview
      luaformatter
      chafa
      patchelf
      ansifilter
      nur.repos.xddxdd.wechat-uos
      nur.repos.linyinfeng.wemeet
      # TODO: https://github.com/NixOS/nixpkgs/pull/243429
      nur.repos.Freed-Wu.netease-cloud-music
      # }}} c++ #
      xsel
    ] ++ (lib.optionals services.xserver.desktopManager.gnome.enable
      [
        gnome.gnome-tweaks
        gnome-randr
        # https://extensions.gnome.org/extension/5263/gtk4-desktop-icons-ng-ding/
        gnomeExtensions.gtk4-desktop-icons-ng-ding
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.appindicator
        gnomeExtensions.screen-rotate
        # TODO: https://github.com/NixOS/nixpkgs/pull/243032
        nur.repos.Freed-Wu.g3kb-switch
      ]) ++ (lib.optionals
      (
        hardware.opengl ? extraPackages && builtins.elem intel-compute-runtime hardware.opengl.extraPackages
      )
      [
        intel-gpu-tools
      ])
    # wl-clipboard breaks vim / firefox
    # ++ (
    #   if services.xserver.displayManager.gdm ? wayland && ! services.xserver.displayManager.gdm.wayland then
    #     [ xsel ]
    #   else [ wl-clipboard ]
    # )
  ;

  # program {{{ #
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.rootless.enable = true;
  virtualisation.docker.rootless.setSocketVariable = true;

  services.dockerRegistry.enable = true;
  services.dockerRegistry.enableDelete = true;
  services.dockerRegistry.enableGarbageCollect = true;
  services.v2raya.enable = true;

  programs.nix-ld.enable = true;
  programs.proxychains.enable = true;
  # https://github.com/NixOS/nixpkgs/pull/222667
  programs.proxychains.package = pkgs.proxychains-ng;
  programs.proxychains.proxies = {
    myproxy = {
      type = "socks5";
      host = "127.0.0.1";
      port = 1080;
    };
  };
  programs.less.envVariables = {
    LESS = "--mouse -S -I -R -M";
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
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.enableSSHSupport = true;
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

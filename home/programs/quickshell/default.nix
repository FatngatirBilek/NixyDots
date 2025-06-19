{
  config,
  lib,
  ...
}: let
  homeDir = config.home.homeDirectory;
  quickshellDir = "${homeDir}/.config/nixos/home/programs/quickshell/qml";
  quickshellTarget = "${homeDir}/.config/quickshell";
  faceIconSource = "${homeDir}/.config/nixos/hosts/laptop/profile_picture.png";
  faceIconTarget = "${homeDir}/.face.icon";
in {
  home.activation.symlinkQuickshellAndFaceIcon = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ln -sfn "${quickshellDir}" "${quickshellTarget}"
    ln -sfn "${faceIconSource}" "${faceIconTarget}"
  '';
}

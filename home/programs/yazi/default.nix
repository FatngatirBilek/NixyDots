{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";

    settings = {
      log = {enabled = false;};
      manager = {
        show_hidden = false;
        sort_by = "alphabetical";
        sort_dir_first = true;
        sort_reverse = true;
      };
    };
  };
}

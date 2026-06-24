return {
  {
    "Mirsmog/real-icons.nvim",

    build = ":RealIconsInstallPack material",

    opts = {
      pack = "material",

      integrations = {
        telescope = true,
        neo_tree = true, -- если используешь Neo-tree
        snacks_picker = true, -- LazyVim использует Snacks
      },
    },
  },
}

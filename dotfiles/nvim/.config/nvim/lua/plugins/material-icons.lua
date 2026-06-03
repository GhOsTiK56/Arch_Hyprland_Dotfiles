return {
  {
    "DaikyXendo/nvim-material-icon",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-web-devicons").setup({
        default = true,
        color_icons = true,
      })
    end,
  },
}

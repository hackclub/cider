module.exports = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        red: "#B93C3C",
        "soft-white": "#FFFFFB",
      },
      fontFamily: {
        garamond: ["VC Garamond", "Garamond", "serif"],
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};

module.exports = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        red: "#ec3750",
        "soft-white": "#FFFFFB",
        "hack-black": "#17171d",
        "hack-blue": "#338eda",
        "hack-green": "#33d6a6",
        "hack-orange": "#ff8c37",
        "hack-purple": "#8057ff",
        "hack-yellow": "#ffaf26",
        "hack-muted": "#7a787d",
        "hack-smoke": "#f5f5f7",
      },
      fontFamily: {
        garamond: ["VC Garamond", "Garamond", "serif"],
        sans: ["Phantom Sans", "system-ui", "sans-serif"],
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};

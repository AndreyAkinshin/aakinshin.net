/** @type {import('tailwindcss').Config} */

const colors = require('tailwindcss/colors')
module.exports = {
  darkMode: 'class',
  content: [
    "./layouts/**/*.{html,js}",
    "./resources/extras/**/*.md",
    "./content/**/*.md"
  ],
  theme: {
    extend: {
      colors: {
        'back': {
          'l': colors.white,
          'd': colors.zinc["800"],
        },
        'back-accent': {
          'l': colors.sky["800"],
          'd': colors.zinc["900"],
        },
        'back-accent-hover': {
          'l': colors.sky["700"],
          'd': colors.zinc["700"],
        },
        'back2': {
          'l': colors.gray["100"],
          'd': colors.zinc["700"],
        },
        'front': {
          'l': colors.black,
          'd': colors.zinc["400"],
        },
        'accent': {
          'l': colors.sky["600"],
          'd': colors.white,
        },
        'accent-frame': {
          'l': colors.sky["600"],
          'd': colors.zinc["300"],
        },
        'accent-hover': {
          'l': colors.sky["200"],
          'd': colors.zinc["600"],
        },
        'accent-icon-hover': {
          'l': colors.sky["400"],
          'd': colors.blue["300"],
        },
        'shadow': {
          'l': colors.gray["300"],
          'd': colors.zinc["600"],
        },
        'frame': {
          'l': colors.gray["300"],
          'd': colors.zinc["600"],
        },
        'alert-text': {
          'l': colors.orange["700"],
          'd': colors.orange["700"],
        },
        'alert-frame': {
          'l': colors.orange["700"],
          'd': colors.orange["700"],
        }
      }
    }
  },
  plugins: [],
}

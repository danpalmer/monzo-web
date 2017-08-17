### Monzo Web

This application is a basic browser for Monzo account data on the web. It's a
'single page application', and has no server-side requirement beyond the Monzo
API itself.

The application is written in Elm and Sass, and is an attempt for me to learn:

 - Elm as a language
 - The Elm architecture
 - A modern and opinionated form of Sass (no `col-xs-12` for me please)
 - Webpack
 - More 'modern' web APIs like push-state, history, etc.

#### Project Setup

This project requires that you have Elm 0.18 installed, and a recent Node
environment set up (tested on v6.5.0).

 - To install dependencies, run `npm run install-all`
 - To run for development, `npm start`
 - To build for production, `npm run build`

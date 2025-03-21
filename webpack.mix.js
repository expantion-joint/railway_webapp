const mix = require('laravel-mix');

/*
 |--------------------------------------------------------------------------
 | Mix Asset Management
 |--------------------------------------------------------------------------
 |
 | Mix provides a clean, fluent API for defining some Webpack build steps
 | for your Laravel application. By default, we are compiling the Sass
 | file for the application as well as bundling up all the JS files.
 |
 */

if (mix.inProduction()) {
  mix.setPublicPath('src/public');  // 本番環境
} else {
  mix.setPublicPath('public'); // 開発環境
}

mix
  .sass('app/assets/stylesheets/sass/app.scss', 'public/css/app.css')
  .js('app/javascript/app.js', 'public/js/app.js')
  .js('app/javascript/turbo.js', 'public/js/turbo.js');
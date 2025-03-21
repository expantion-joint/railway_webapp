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

 mix.setPublicPath('public'); // 共通設定

 mix
   .sass('app/assets/stylesheets/sass/app.scss', 'css')
   .js('app/javascript/app.js', 'js')
   .js('app/javascript/turbo.js', 'js');
 
 if (mix.inProduction()) {
   mix.version(); // 本番環境のみハッシュ付き出力
 }

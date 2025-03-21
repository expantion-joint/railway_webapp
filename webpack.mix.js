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
    mix.setPublicPath('public')
    .sass('app/assets/stylesheets/sass/app.scss', 'css')
    .js('app/javascript/app.js', 'js')
    .js('app/javascript/turbo.js', 'js')
    .version(); // ← ハッシュ付きファイルを生成し、キャッシュ回避
}

if (mix.inDevelopment()) {
    mix.setPublicPath('public')
    .sass('app/assets/stylesheets/sass/app.scss', 'public/css/app.css')
    .js('app/javascript/app.js', 'public/js/app.js')
    .js('app/javascript/turbo.js', 'public/js/turbo.js');
}
    

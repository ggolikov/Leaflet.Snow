import '../../src/L.Snow';
// import { points } from './points';

$('#colorpicker').colorpicker();

var osm = L.tileLayer('http://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
    }),
    center = [48, 10],
    lmap = new L.Map('map', {layers: [osm], center, zoom: 5, maxZoom: 22, zoomAnimation: true}),

    root                  = document.querySelector('#content'),
    colorpickerController = document.querySelector('#colorpicker input'),
    speedController       = document.querySelector('.speed-controller'),
    layersCountController     = document.querySelector('.layersCount-controller'),
    densityController     = document.querySelector('.density-controller'),
    sizeController        = document.querySelector('.size-controller'),

    options = {
        speed:          +speedController.value,          // times
        layersCount:    +layersCountController.value,          // times
        density:        +densityController.value,          // times
        size:           +sizeController.value,          // times
        color:          rgb2hex(colorpickerController.value),
        opacity: 0.5
    },
    points = [
        [
            [35, -5],
            [60, -5],
            [60, 25],
            [35, 25],
            [35, -5]
        ]
    ],
    snow = L.snow(points, options).addTo(lmap);
    window.snow = snow;

speedController.addEventListener('change', function (e) {
    var speed = Number(e.target.value);
    snow.setSpeed(speed);
});

layersCountController.addEventListener('change', function (e) {
    var layersCount = Number(e.target.value);
    snow.setLayersCount(layersCount);
});

densityController.addEventListener('change', function (e) {
    var density = Number(e.target.value);
    snow.setDensity(density);
});

sizeController.addEventListener('change', function (e) {
    var size = Number(e.target.value);
    snow.setSize(size);
});

$('#colorpicker').on('colorpickerChange', e => {
    var color = e.color.toHexString(),
        opacity = e.color.alpha;

    snow.setColor(color);
    snow.setOpacity(opacity);
});

function rgb2hex(rgb) {
    rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
    return '#' + ("0" + parseInt(rgb[1],10).toString(16)).slice(-2) + ("0" + parseInt(rgb[2],10).toString(16)).slice(-2) + ("0" + parseInt(rgb[3],10).toString(16)).slice(-2);
}

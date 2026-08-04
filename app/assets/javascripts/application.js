// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require_tree .

(function() {
  function setupPhotographyViewer(viewer) {
    var track = viewer.querySelector('[data-photography-track]');
    var slides = viewer.querySelectorAll('.photography-slide');
    var current = 0;
    var timer;

    function showSlide(index) {
      current = (index + slides.length) % slides.length;
      track.style.transform = 'translateX(-' + (current * 100) + '%)';
    }

    function startRotation() {
      window.clearInterval(timer);
      if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        timer = window.setInterval(function() { showSlide(current + 1); }, 5000);
      }
    }

    viewer.querySelector('[data-carousel-previous]').addEventListener('click', function() {
      showSlide(current - 1);
      startRotation();
    });
    viewer.querySelector('[data-carousel-next]').addEventListener('click', function() {
      showSlide(current + 1);
      startRotation();
    });
    startRotation();
  }

  document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('[data-photography-viewer]').forEach(setupPhotographyViewer);
  });
})();

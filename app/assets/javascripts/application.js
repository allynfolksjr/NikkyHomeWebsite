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
    var slides = viewer.querySelectorAll('.photography-slide');
    var links = viewer.querySelectorAll('.photography-slide a');
    var previous = viewer.querySelector('[data-carousel-previous]');
    var next = viewer.querySelector('[data-carousel-next]');
    var pause = viewer.querySelector('[data-carousel-pause]');
    var indicator = viewer.querySelector('[data-carousel-indicator]');
    var current = 0;
    var timer;
    var manuallyPaused = false;
    var temporarilyPaused = false;

    function showSlide(index, moveFocus) {
      current = (index + slides.length) % slides.length;
      Array.prototype.forEach.call(slides, function(slide, index) {
        var active = index === current;
        slide.setAttribute('aria-hidden', active ? 'false' : 'true');
        slide.hidden = !active;
        links[index].tabIndex = active ? 0 : -1;
      });
      indicator.textContent = (current + 1) + ' of ' + slides.length;
      if (moveFocus) links[current].focus();
    }

    function startRotation() {
      window.clearInterval(timer);
      if (!manuallyPaused && !temporarilyPaused && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        timer = window.setInterval(function() { showSlide(current + 1, false); }, 5000);
      }
    }

    function pauseTemporarily() {
      temporarilyPaused = true;
      window.clearInterval(timer);
    }

    function resumeAfterTemporaryPause() {
      temporarilyPaused = false;
      startRotation();
    }

    previous.addEventListener('click', function() {
      showSlide(current - 1, true);
      startRotation();
    });
    next.addEventListener('click', function() {
      showSlide(current + 1, true);
      startRotation();
    });
    pause.addEventListener('click', function() {
      manuallyPaused = !manuallyPaused;
      pause.textContent = manuallyPaused ? 'Resume' : 'Pause';
      pause.setAttribute('aria-label', manuallyPaused ? 'Resume slideshow' : 'Pause slideshow');
      startRotation();
    });
    viewer.addEventListener('keydown', function(event) {
      if (event.key === 'ArrowLeft') {
        event.preventDefault();
        showSlide(current - 1, true);
        startRotation();
      } else if (event.key === 'ArrowRight') {
        event.preventDefault();
        showSlide(current + 1, true);
        startRotation();
      } else if (event.key === 'Home') {
        event.preventDefault();
        showSlide(0, true);
        startRotation();
      } else if (event.key === 'End') {
        event.preventDefault();
        showSlide(slides.length - 1, true);
        startRotation();
      }
    });
    viewer.addEventListener('mouseenter', pauseTemporarily);
    viewer.addEventListener('mouseleave', resumeAfterTemporaryPause);
    viewer.addEventListener('focusin', pauseTemporarily);
    viewer.addEventListener('focusout', function(event) {
      if (!viewer.contains(event.relatedTarget)) resumeAfterTemporaryPause();
    });
    startRotation();
  }

  document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('[data-photography-viewer]').forEach(setupPhotographyViewer);
  });
})();

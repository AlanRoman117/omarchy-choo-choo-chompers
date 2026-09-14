/* Choo-Choo Chompers chunk loader. Every file here is a plain script; this
 * wires the AMD chunks together once they have all loaded. No network, no eval. */
(function () {
  'use strict';
  var definitions = Object.create(null);
  var modules = Object.create(null);

  function load(id) {
    id = id.replace(/^\.\//, '').replace(/\.js$/, '');
    if (modules[id]) return modules[id].exports;
    var definition = definitions[id];
    if (!definition) throw new Error('chunk loader: no chunk named ' + id);
    var module = (modules[id] = { exports: {} });
    var args = definition.deps.map(function (dep) {
      return dep === 'exports' ? module.exports : load(dep);
    });
    definition.factory.apply(null, args);
    return module.exports;
  }

  window.define = function (id, deps, factory) {
    if (typeof id !== 'string' || definitions[id]) throw new Error('chunk loader: bad define');
    definitions[id] = { deps: deps, factory: factory };
  };

  var entry = document.currentScript.getAttribute('data-entry');
  document.addEventListener('DOMContentLoaded', function () {
    load(entry);
  });
})();

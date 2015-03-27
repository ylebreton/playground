(function () {
  angular.module('MainApp', ['anguFixedHeaderTable']);
})();
(function () {
  angular.module('MainApp').controller('MyController', function($scope, $timeout) {
    function changeLines(max) {
      var items = [], i;
      for (i=1; i <= max; i++) {items.push(i)}
      $scope.lines = items;
      console.log('changed lines to:' + $scope.lines.length);
    }

    console.log('starting');
    changeLines(2);

    $timeout(function() {changeLines(10);}, 1000);
    $timeout(function() {changeLines(20);}, 5000);
    $timeout(function() {changeLines(30);}, 10000);
    console.log('done');
  });
})();

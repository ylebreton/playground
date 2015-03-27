angular.module('apidoc', ['ui.bootstrap', 'ngSanitize']);

angular.module('apidoc').config(['$httpProvider', function($httpProvider) {
  $httpProvider.defaults.useXDomain = true;
  delete $httpProvider.defaults.headers.common['X-Requested-With'];
}
]);

angular.module('apidoc').factory('CallResult', function CallResultFactory() {
  return function (url) {
    var formatXml = function (xml) {
        var formatted = '',
          reg = /(>)(<)(\/*)/g,
          pad = 0;
        xml.replace(reg, '$1\r\n$2$3').split('\r\n').forEach(function (node) {
          var indent = 0;
          if (node.match( /.+<\/\w[^>]*>$/ )) {
            indent = 0;
          } else if (node.match( /^<\/\w/ )) {
            if (pad != 0) {
              pad -= 1;
            }
          } else if (node.match( /^<\w[^>]*[^\/]>.*$/ )) {
            indent = 1;
          } else {
            indent = 0;
          }

          var padding = '';
          for (var i = 0; i < pad; i++) {
            padding += '  ';
          }

          formatted += padding + node + '\r\n';
          pad += indent;
        });

        return formatted;
      },
      prettyString = function (type, value) {
        if (type && (type.indexOf('xml') >= 0 || type.indexOf('rss') >= 0)) {
          return formatXml(value.trim());
        } else if (type && type.indexOf('json') >= 0) {
          return JSON.stringify(value, null, 2);
        } else {
          return value;
        }
      },
      result = {
        url: url,
        contentType: 'json',
        load:function(data, status, headersFct) {
          var headers = headersFct();
          result.status = status;
          result.headers = headers;
          if (headers['content-type']) {
            result.contentType = headers['content-type'];
          }
          result.headersPretty = prettyString('json', headers);
          result.data = data;
          result.dataPretty = prettyString(result.contentType, data);
        }
      };
    return result;
  };
});

angular.module('apidoc').filter('highlight', function () { //there is an issue in ui-utils' highlight: it doesn't ignore html tags
  return function (text, search, caseSensitive) {
    var searchPattern,
      textStr = text ? text.toString() : '',
      hasSearch = search !== undefined && (search !== '' || angular.isNumber(search)),
      callback = function callback(p1, p2) {
        return ((p2 === undefined) || p2 === '') ? p1 : '<span class="ui-match">'+p1+'</span>';
      };

    if (textStr.length > 0 && hasSearch) {
      searchPattern = '<[^>]+>|(' + search.toString() + ')';
      if (caseSensitive) {
        return textStr.replace(new RegExp(searchPattern, 'g'), callback);
      } else {
        return textStr.replace(new RegExp(searchPattern, 'gi'), callback);
      }
    } else {
      return text;
    }
  };
});

angular.module('apidoc').controller('Loader', function($scope, $http, CallResult) {
  var showSetup = {
    showResponseCode: false,
    showHeaders: false,
    codeSample: '',
    sampleTypes: ['Javascript', 'curl'],
    filterByEndpointName:true,
    filterByMethodName:true,
    filterByMethodDescription:true,
    filterByParameterName:true,
    filterByParameterDescription:true
  };

  function foundIn(criteria, value) { return value ? value.toLowerCase().indexOf(criteria) >= 0 : false; }

  $scope.apis = [];
  $scope.securityToken = '';
  $scope.criteria = '';
  $scope.showSetup = showSetup;
  $scope.isShowSetupCollapsed = true;

  function foundInMethod(criteria, method) {
    var foundInParams = _.find(method.parameters, function (parameter) {
      return foundIn(criteria, parameter.Name, showSetup.filterByParameterName) || foundIn(criteria, parameter.Description, showSetup.filterByParameterDescription);
    });
    return foundIn(criteria, method.MethodName, showSetup.filterByMethodName) || foundIn(criteria, method.Synopsis, showSetup.filterByMethodDescription) || foundInParams !== undefined;
  }
  function foundInEndpoint(criteria, endpoint) {
    var foundInMethods = _.find(endpoint.methods, function (method) { return foundInMethod(criteria, method); });
    return foundIn(criteria, endpoint.name, showSetup.filterByEndpointName) || foundInMethods !== undefined;

  }

  $scope.apiMatch = function (query) {
    var criteria = query ? query.toLowerCase() : '';

    return function (api) {
      if (criteria === '') {
        return api.data.endpoints.length > 0;
      } else {
        return _.find(api.data.endpoints, function (endpoint) {
          return foundInEndpoint(criteria, endpoint);
        });
      }
    };
  };
  $scope.endpointMatch = function (query) {
    var criteria = query ? query.toLowerCase() : '';
    return function (endpoint) {
      if (criteria === '') {
        return true;
      } else {
        return foundInEndpoint(criteria, endpoint);
      }
    };
  };
  $scope.methodMatch = function (query, endpoint) {
    var criteria = query ? query.toLowerCase() : '';
    return function (method) {
      if (criteria === '' || foundIn(criteria, endpoint.name)) {
        return true;
      } else {
        return foundInMethod(criteria, method);
      }
    };
  };

  $scope.clearResults = function (method) {
    method.call = undefined;
  };

  $scope.runMethod = function(method) {
    var executor = $http[method.HTTPMethod.toLowerCase()],
      url = method.url,
      params = {},
      displaySamples = {
        'Javascript': function () {
          return '$.ajax("' + url + '", {\n  crossDomain: true, \n  data: ' + JSON.stringify(params) + ', \n  type:"' + method.HTTPMethod + '", \n  success: function(data) {\n    console.log(JSON.stringify(data));\n  }\n});';
        },
        'curl': function () {
          var key, paramsString = '';
          for (key in params) {
            if (params.hasOwnProperty(key)) {
              paramsString = paramsString + '&' + key + '=' + encodeURIComponent(params[key]);
            }
          }
          if (method.HTTPMethod === 'GET') {
            return 'curl "' + url + '?' + paramsString + '"';
          } else if (method.HTTPMethod === 'POST') {
            return 'curl -d "' +paramsString + '" ' + url;
          } else {
            return 'Not Supported';
          }
        },
        '': function () {
          return '';
        }
      };

    if (method.RequiresOAuth === 'Y') {
      params['api_token'] = $scope.securityToken;
    }

    method.parameters.forEach(function (parameter) {
      if (parameter.value) {
        var urlParam = ':' + parameter.Name;

        if (url.indexOf(urlParam) >= 0) {
          url = url.replace(urlParam, parameter.value);
        } else {
          params[parameter.Name] = parameter.value;
        }
      }
    });

    method.call = CallResult(url);
    method.updateSample = function () {
      var sample = showSetup.codeSample;
      if (displaySamples.hasOwnProperty(sample)) {
        method.codeSample =  displaySamples[sample]();
      } else {
        method.codeSample =  '';
      }
    };
    method.updateSample();

    executor(url, {params: params}).success(method.call.load).error(method.call.load);
  };
  $scope.lineCount = function (text) {
    if (text)
      return text.split('\n').length;
    else
      return 1;
  };

  ['foursquare'].forEach(function (name) {
    $http.get('data/' + name + '.json')
      .then(function(result) {
        var data = result.data;
        $scope.apis.push({name:name, data:data});

        (data.endpoints || []).forEach(function (endpoint) {
          (endpoint.methods || []).forEach(function (method) {
            method.url = (data.basePath || '') + method.URI;
            (method.parameters || []).forEach(function (parameter) {
               parameter.value = parameter.Default;
            });
          });
        });
      });

  });
});
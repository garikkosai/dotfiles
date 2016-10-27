mkdir angular_project_name
touch angular_project_name/Gruntfile.js
touch angular_project_name/package.json

mkdir angular_project_name/app
mkdir angular_project_name/app/css
touch angular_project_name/app/css/main.less
mkdir angular_project_name/app/img
mkdir angular_project_name/app/js

mkdir angular_project_name/app/js/controllers
touch angular_project_name/app/js/controllers/MainCtrl.js

mkdir angular_project_name/app/js/partials
touch angular_project_name/app/js/partials/main.html

mkdir angular_project_name/app/js/services
touch angular_project_name/app/js/services/ApiClient.js
touch angular_project_name/app/js/services/Formatter.js
touch angular_project_name/app/js/services/LocalSession.js
touch angular_project_name/app/js/services/Session.js

touch angular_project_name/app/js/app.js
touch angular_project_name/app/js/routes.js

mkdir angular_project_name/app/vendor
touch angular_project_name/app/index.html

mkdir angular_project_name/release
mkdir angular_project_name/release/img
mkdir angular_project_name/release/partials
mkdir angular_project_name/release/vendor

echo '{
  "name": "main-api",
  "version": "0.1.0",
  "devDependencies": {
    "grunt": "~1.0.1",
    "grunt-contrib-uglify": "~2.0.0",
    "grunt-contrib-less": "~1.4.0",
    "requestify": "~0.2.3",
    "node-static": "~0.7.7",
    "grunt-contrib-copy": "~1.0.0",
    "grunt-contrib-watch": "~1.0.0"
  }
}' > angular_project_name/package.json

echo "module.exports = function(grunt) {

    // Project configuration.
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        uglify: {
            options: {
                sourceMap: true
            },
            build: {
                src: 'app/js/**/*.js',
                dest: 'release/main-api.js'
            }
        },
        less: {
            build: {
                files: {
                    'release/main-api.css': 'app/css/*.less',
                }
            }
        },
        copy: {
            build: {
                files: [
                    {
                        src: 'app/index.html',
                        dest: 'release/index.html'
                    },
                    {
                        expand: true,
                        cwd: 'app/js/partials/',
                        src: '**',
                        dest: 'release/partials/'
                    },
                    {
                        expand: true,
                        cwd: 'app/img/',
                        src: '**',
                        dest: 'release/img/'
                    },
                    {
                        expand: true,
                        cwd: 'app/vendor/',
                        src: '**',
                        dest: 'release/vendor/'
                    },
                ]
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-uglify');

    // Default task(s).
    grunt.registerTask('default', ['uglify', 'less', 'copy']);
};" > angular_project_name/Gruntfile.js

echo "'use strict';

var DEPENDENCIES = [
    '\$scope',
    'Session',
];

function MainCtrl (
    \$scope,
    Session
) {
    \$scope.isLoggedIn = function() {
        return Session.isLoggedIn();
    };
}

MainCtrl.\$inject = DEPENDENCIES;" > angular_project_name/app/js/controllers/MainCtrl.js

echo "'use strict';

var DEPENDENCIES = [
    '\$http',
    'Session'
];

function ApiClientFactory(
    \$http,
    Session
) {
    var URI_BASE = '';

    function ApiClient() {
    }

    ApiClient.prototype.authed = function(path, data) {
        if (!data) {
            data = {};
        }

        data.user_id = Session.user;
        data.session_id = Session.session_id;
        return this._request(path, data, 'POST');
    };

    ApiClient.prototype.call = function(path, data) {
    };

    ApiClient.prototype.post = function(path, data) {
        return this._request(path, data, 'POST');
    };

    ApiClient.prototype.get = function(path) {
        return this._request(path, null, 'GET');
    };

    ApiClient.prototype._request = function(path, postData, method) {
        var promise = \$http({
            url: URI_BASE + path,
            method: method,
            withCredentials: true,
            data: JSON.stringify(postData)
        });

        return this._responseHandler(promise);
    };

    ApiClient.prototype._responseHandler = function(promise) {
        return promise.then(
            function(resp) { return resp.data; },
            function(resp) {
                // TBD: handle not-authorized, redirect to login page
                var out = resp.data || {};
                out.error = true;
                return out;
            }
        );
    };

    return new ApiClient();
}

ApiClientFactory.\$inject = DEPENDENCIES;" > angular_project_name/app/js/services/ApiClient.js

echo "'use strict';

var DEPENDENCIES = [
];

function FormatterFactory(
) {
    function Formatter() {
    }

    Formatter.prototype.time = function(epoch) {
        return  (new Date( new Date(epoch * 1000) ).toLocaleDateString());
    };

    Formatter.prototype.truncate = function(text) {
        if (text) {
            if (text.length > 50) {
                return (text.substr(0, 47) + '...');
            }
            else {
                return text;
            }
        }
        else {
            return '';
        }
    };

    return new Formatter();
}

FormatterFactory.\$inject = DEPENDENCIES;" > angular_project_name/app/js/services/Formatter.js

echo "'use strict';

var DEPENDENCIES = [
    '\$cookies'
];

function LocalSessionFactory (
    \$cookies
) {
    var NAME = '_jsStore';

    function LocalSession() {
        // On load, check the cookie for values from a previous session
        var json = \$cookies.get(NAME);
        if (json) {
            this._dict = this.deserialize(json);
        }
        else {
            this._dict = {};
        }
    }

    LocalSession.prototype.put = function(key, value) {
        this._dict[key] = value;

        // Update the persistent storage
        \$cookies.put(NAME, this.serialize());
    };

    LocalSession.prototype.get = function(key) {
        return this._dict[key];
    };

    LocalSession.prototype.serialize = function() {
        return JSON.stringify(this._dict);
    };

    LocalSession.prototype.deserialize = function(string) {
        return JSON.parse(string);
    };

    return new LocalSession();
}

LocalSessionFactory.\$inject = DEPENDENCIES;" > angular_project_name/app/js/services/LocalSession.js

echo "'use strict';

var DEPENDENCIES = [
    'LocalSession',
];

function SessionFactory(
    LocalSession,
    RefreshService
) {
    function Session() {
        this.user = LocalSession.get('user_id');
        this.session_id = LocalSession.get('session_id');
    }

    Session.prototype.setSession = function (user, session) {
        this.user = user;
        this.session_id = session;

        LocalSession.put('user_id', this.user);
        LocalSession.put('session_id', this.session_id);
    };

    Session.prototype.logout = function() {
        this.setSession(null, null);
    };

    Session.prototype.isLoggedIn = function() {
        return !!this.session_id;
    };

    return new Session();
}

SessionFactory.\$inject = DEPENDENCIES;" > angular_project_name/app/js/services/Session.js

echo "angular.module('main-app', ['ngRoute', 'ngCookies'])
    // Enter utility
    .directive('utilEnter', function () {
        return function (scope, element, attrs) {
            element.bind('keydown keypress', function (event) {
                if(event.which === 13) {
                    scope.\$apply(function (){
                        scope.\$eval(attrs.utilEnter);
                    });
                    event.preventDefault();
                }
            });
        };
    })

    // Disable angular debugging
    .config(
        [
            '\$compileProvider',
            function ($compileProvider) {
                \$compileProvider.debugInfoEnabled(false);
            }
        ]
    )

    // Controllers
    .controller('MainCtrl', MainCtrl)


    // Services
    .factory('ApiClient', ApiClientFactory)
    .factory('Formatter', FormatterFactory)
    .factory('LocalSession', LocalSessionFactory)
    .factory('Session', SessionFactory)
;

" > angular_project_name/app/js/app.js

echo "var DEPENDENCIES = ['\$routeProvider'];

function RouteController($routeProvider) {
    \$routeProvider
        .when('/', {
            templateUrl: 'partials/main.html',
            controller: 'MainCtrl',
        })

        .otherwise({ redirectTo: '/' });
}

RouteController.\$inject = DEPENDENCIES;

angular.module('main-app').config(RouteController);" > angular_project_name/app/js/routes.js

echo "<!DOCTYPE html>
<html>
<head>
    <link href='https://fonts.googleapis.com/css?family=Lato:400,700' rel='stylesheet' type='text/css'>
    <script src='vendor/angular.min.js'></script>
    <script src='vendor/lodash.min.js'></script>
    <script src='vendor/angular-route.min.js'></script>
    <script src='vendor/angular-cookies.min.js'></script>
    <script src='main-api.js'></script>
    <link rel='stylesheet' href='main-api.css'>
    <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css'>
</head>
<body ng-app='main-app' ng-controller='MainCtrl'>

    <div>
        <ng-view></ng-view>
    </div>
</div>
</body>
</html>" > angular_project_name/app/index.html

echo "<h1>This is the Main.html Partial</h1>" > angular_project_name/app/js/partials/main.html


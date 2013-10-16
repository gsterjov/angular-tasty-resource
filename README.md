TastyResource
=============

This AngularJS module is intended to be a lightweight handler for TastyPie's REST resources for Django. It tries to be similar to Angular's $resource in the ways it defines and retrieves resources.

TastyResource is written in CoffeeScript, but compiled versions will be included in the repository


Usage
=====

TastyResource makes no attempt to be generic in its handling of REST interfaces. Its sole focus on TastyPie makes usage and configuration a snap.

Below is an example program that defines a resource and uses it in a controller.

	app = angular.module("myapp", ["tastyResource"]);

	app.factory("User", ["TastyResource", function (TastyResource) {
		return TastyResource({
			url: "/api/v1/user/",
			cache: true
		});
	}]);


	app.controller("MyController", ["$scope", "User", function ($scope, User) {
		$scope.users = User.query();
		$scope.user = User.get(1);

		$scope.create = function() {
			user = User;
			user.firstname = "John";
			user.lastname = "Doe";
			user.post();
		}

		$scope.edit = function(){
			$scope.user.firstname = "Jane";
			$scope.user.lastname = "Doe";
			$scope.user.put();
		}
	}]);



Features
========

TastyResource also takes advantage of certain TastyPie features. Below are some examples of these features being used.

Filters
-------

Make use of the filter features on TastyPie by passing an object to the query function.

	user = User.query({ firstname: "Jane", lastname: "Doe" });


Relationships
-------------

Although TastyResource doesn't attempt to stub out URIs in the return resources, it does understand when trying to retrieve and save resource URIs.

	user = User.get(1);
	profile = Profile.get(user.profile);

	new_profile = Profile;
	new_profile.country = "Australia";
	new_profile.post();

	user.profile = new_profile;
	user.put();

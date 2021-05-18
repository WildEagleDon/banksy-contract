const PeopleAroundPlanet = artifacts.require("PeopleAroundPlanet");

module.exports = function(deployer) {
    deployer.deploy(PeopleAroundPlanet);
};
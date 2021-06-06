class Country {
  String country;
  String nationality;
  String iso2;
  // List<State> states;

  Country(this.country, this.nationality, this.iso2
      // , this.states
      );

  Country.fromJson(dynamic country)
      : this(
          country["country"],
          country["nationality"],
          country["iso2"],
        );
}

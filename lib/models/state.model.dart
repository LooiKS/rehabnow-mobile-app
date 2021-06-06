class ResidentialState {
  String state;
  int id;
  // List<City> cities;

  ResidentialState(this.state, this.id) {
    // print(cities);
  }

  ResidentialState.fromJson(dynamic state)
      : this(
          state["state"], state["id"],
          // state["cities"].map<City>((city) => City.fromJson(city)).toList()
        );
}

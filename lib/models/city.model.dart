class City {
  String city;
  City(this.city);
  City.fromJson(dynamic city) : this(city["city"]);
}

class ResidentialState {
  String state;
  int id;

  ResidentialState(this.state, this.id);

  ResidentialState.fromJson(dynamic state)
      : this(
          state["state"],
          state["id"],
        );
}

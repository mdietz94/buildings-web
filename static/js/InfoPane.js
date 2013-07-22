function InfoPane(){
	// empty constructor
}

InfoPane.prototype.load(id){
	// let's make sure we have all the data
	bldg = Buildings.get(id)
	bldg.load()
}
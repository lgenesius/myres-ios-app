import Foundation

enum Category: String {
    case publicBuilding
    case holyPlace
    case outdoor
    case art
    case water
    case nature
    case house
    case none
}

struct PhotoCategory {
    static let photoCategoryDict: [String: [String]] = [
        "publicBuilding": ["airport_terminal", "arch", "auditorium", "ballroom", "banquet_hall", "bar", "beauty_salon", "bookstore", "bowling_alley", "boxing_ring", "bus_interior", "butchers_shop", "bakery/shop", "cafetaria", "candy_store", "classroom", "clothing_store", "cockpit", "coffee_shop", "conference_center", "conference_room", "courthouse", "fire_station", "food_court", "galley", "gas_station", "gift_shop", "hospital", "kindergarden_classroom", "laundromat", "lobby", "martial_arts_gym", "motel", "market/outdoor", "nursery", "office_building", "parking_lot", "phone_booth", "reception", "residential_neighborhood", "restaurant", "restaurant_kitchen", "restaurant_patio", "schoolhouse", "shoe_shop", "shopfront", "ski_resort", "ski_slope", "slum", "supermarket", "stadium/baseball", "stadium/football", "subway_station/platform", "train_station/platform", "waiting_room", "amusement_park", "assembly_line", "construction_site", "engine_room", "excavation"],
        
        "holyPlace": ["abbey", "basilica", "cemetery", "cathedral/outdoor", "church/outdoor", "mausoleum", "medina", "monastery/outdoor", "pagoda", "pulpit", "temple/east_asia", "temple/south_asia"],
        
        "outdoor": ["alley", "baseball_field", "boardwalk", "bridge", "butte", "courtyard", "driveway", "fairway", "garbage_dump", "golf_course", "highway", "ice_cream_parlor", "ice_skating_rink/outdoor", "inn/outdoor", "orchard", "picnic_area", "playground", "plaza", "racecourse", "railroad_track", "rope_bridge", "runway", "skyscraper", "tower", "train_railway", "track/outdoor", "viaduct", "yard"],
        
        "art": ["amphitheater", "art_gallery", "art_studio", "building_facade", "castle", "kasbah", "museum/indoor", "palace", "ruin"],
        
        "water": ["aquarium", "aqueduct", "boat_deck", "coast", "dam", "fountain", "harbor", "hot_spring", "lighthouse", "ocean", "pond", "raft", "sea_cliff", "swimming_pool/outdoor", "trench", "underwater/coral_reef", "water_tower", "watering_hole"],
        
        "nature": ["badlands", "bamboo_forest", "bayou", "botanical_garden", "campsite", "canyon", "corn_field", "cottage_garden", "creek", "crevasse", "desert/sand", "desert/vegetation", "forest_path", "forest_road", "formal_garden", "field/cultivated", "field/wild", "herb_garden", "iceberg", "igloo", "islet", "marsh", "mountain", "mountain_snowy", "pasture", "rainforest", "rice_paddy", "rock_arch", "sandbar", "sky", "snowfield", "swamp", "topiary_garden", "tree_farm", "valley", "vegetable_garden", "volcano", "wheat_field", "wind_farm", "windmill"],
        
        "house": ["attic", "apartment_building/outdoor", "basement", "bedroom", "chalet", "closet", "dorm_room", "dinette/home", "doorway/outdoor", "fire_escape", "game_room", "home_office", "hospital_room", "hotel_room", "jail_cell", "kitchen", "kitchenette", "living_room", "locker_room", "mansion", "music_studio", "office", "pantry", "parlor", "patio", "pavilion", "shed", "shower", "staircase", "stage/indoor", "television_studio", "veranda"]
    ]
    
    var lele: Category
    
    func loadMusic() {
        switch lele {
        default:
            break
        }
    }
}

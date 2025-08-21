//
//  ContentView.swift
//  a1-s3926655
//
//  Created by An Luu on 22/8/24.
//

import SwiftUI


struct HomeView: View {
    @State var dishes = [Dish(name: "Nasi Lemak", type: "Main Dish", image: "Nasi Lemak", isFavorite: false, ingredients: ["Egg", "Rice", "Sambal", "Cucumber", "Anchovie"])]
    var body: some View {
        
        VStack {
            HStack{
                Text("Welcome Home")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "magnifyingglass")
                Image(systemName: "person.crop.circle")
                    .padding(.horizontal)
            }
            .padding()
            
            CategoryTabView()
            
            Rectangle().fill(Color(red: 242 / 255, green: 242 / 255, blue: 242 / 255)).frame(width: .infinity, height: 1, alignment: .center)
            HStack{
                Text("Top dishes of the day")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontWeight(.black)
                    .padding()
                Spacer()
            }
            ScrollView(.horizontal) {
                ForEach(dishes.indices, id: \.self) { index in
                    BasicTextImageRow(dish: $dishes[index])
                }
                
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .padding()
            
        }
        
        Spacer()
        
        
    }
}


struct BasicTextImageRow: View {
    
    // MARK: - Binding
    
    @Binding var dish: Dish
    
    var body: some View {
        VStack{
            Image(dish.image)
                .resizable()
                .frame(width: 120, height: 118)
                .cornerRadius(20)
            
            VStack(alignment: .leading) {
                Text(dish.name)
                    .font(.system(.title2, design: .rounded))
                
                Text(dish.type)
                    .font(.system(.body, design: .rounded))
            }
        }
    }
}

#Preview {
    HomeView()
}

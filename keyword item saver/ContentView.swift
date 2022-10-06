//
//  ContentView.swift
//  keyword item saver
//
//  Created by Robert Wiebe on 2/21/22.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("items") var items: [listItem] = []
    init() {
        UITableView.appearance().backgroundColor = .none
        UITableView.appearance().sectionFooterHeight = 0
    }
    @State var searchingFor = ""
    
    @State var addSheetIsPresented: Bool = false
    @State var editSheetIsPresented: Bool = false
    @State var newListItem: listItem = listItem()
    @State var newTags: [Bool] = [false, false, false, false, false, false, false, false]
    @State var lockedTags: [Tag] = []
    @State var groupBy: GroupingType = .none
//    @State var showingTags: [Tag] = []
    var body: some View {
        NavigationView{
            ZStack {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 20){
                            ForEach(Tag.allTags, id: \.self){tag in
                                Label(tag.name, systemImage: tag.symbol)
                                    .background(
                                        ZStack{
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundColor(tag.color)
                                            .padding(-5)
                                            .opacity(lockedTags.contains(tag) ? 1 : 0)
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(lineWidth: 2)
                                            .foregroundColor(tag.color)
                                            .padding(-5)
                                        }
                                            .shadow(radius: 3)
                                    )
                                    .onTapGesture{
                                        
                                        if lockedTags.contains(tag){
                                            lockedTags = lockedTags.filter { $0 != tag}
                                        }
                                        else{
                                            lockedTags.append(tag)
                                        }
                                        print(lockedTags)

                                    }
                            }
                            if lockedTags.count > 0 {
                                Button(action:{
                                    self.lockedTags.removeAll()
                                }) {
                                    Label("Clear all", systemImage: "xmark")
                                        .foregroundColor(.primary)
                                }
                            }
                        }.padding()
                    }
                    List{
                        Button(action: {self.addSheetIsPresented = true}, label: {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(LinearGradient(colors: [.black, .gray], startPoint: .topLeading, endPoint: .bottom), lineWidth: 10)
                                .blendMode(.screen)
                                .background(Color.blue)
                                .padding(.horizontal, -25)
                                .padding(.vertical, -11)
                                .overlay(
                                    Text("Add item").foregroundColor(.white).bold().shadow(radius: 8)
                                )
                        })
                        .sheet(isPresented: $addSheetIsPresented, content: {
                            NavigationView {
        //                        ZStack {
        //                            Color.gray.opacity(0.2).edgesIgnoringSafeArea(.all)
                                addView(newItem: $newListItem, selectedTags: $newTags)
                                    .toolbar {
                                        ToolbarItem(placement: .primaryAction) {
                                            Button(action: {
                                                if newListItem.isReady{
                                                    newListItem.tags = listToTags(list: newTags)
                                                    items.insert(newListItem, at: 0)
                                                }
                                                self.newListItem = listItem()
                                                self.newTags = [false, false, false, false, false, false, false, false]
                                                self.addSheetIsPresented = false
                                                
                                            }) {
                                                Text("Add").fontWeight(.semibold)
                                            }
                                        }
        //                        }
                                }
                            }
                        })
                        .shadow(radius: 8)
                        
                        Section{
                            HStack {
                                Spacer()
                                Text("Group By:")
                                Picker("Group By:",
                                       selection: $groupBy) {
                                    ForEach(GroupingType.allCases, id: \.self) {
                                        Text($0.description)
                                        }
                                    }.pickerStyle(MenuPickerStyle()
                                )
                            }
                            
                        }
                        
                        ForEach(Array(results.enumerated()), id: \.offset) {groupIndex, group in
                            Section(header: groupBy == .none ? Text("ungrouped") : (groupBy == .category ? Text(showingTags[groupIndex].name) : Text(group[0].selectedContentType.description))) {
//                                Text(String(group.count))
                                ForEach(group, id: \.self){item in
                                    EmptyView()
                                    HStack {
                                        VStack(alignment: .leading){
                                            if !item.allKeywords[0].isEmpty {
                                                Text(item.allKeywords.count > 1 ? item.allKeywords[0] + " +" + String(item.allKeywords.count - 1) : item.allKeywords[0])
                                                    .font(.caption)
                                            }
                                            Text(item.contentToString)
                                                .font(.body.bold())
                                        }
                                        Spacer()
                                        Menu {
//                                            Button(action: {
//                                                self.editSheetIsPresented = true
//                                            }, label: {
//                                                Label("Edit", systemImage: "pencil")
//                                            })
//                                                .sheet(isPresented: $editSheetIsPresented){
//                                                    NavigationView {
//                                                        Text("lol")
    //                                                    editView(editItem: $items[items.firstIndex(of: item)])
    //                                                        .toolbar {
    //                                                            ToolbarItem(placement: .primaryAction) {
    //                                                                Button(action: {
    //                                                                    self.editSheetIsPresented = false
    //
    //                                                                }) {
    //                                                                    Text("Done").fontWeight(.semibold)
    //                                                                }
    //                                                            }
    //                                                    }
//                                                    }
//                                                }
                                            Button(role: .destructive, action: {
                                                items.remove(at: items.firstIndex(of: item)!)
                                            }, label: {
                                                Label("Delete", systemImage: "trash")
                                            })
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    
                                }.onDelete{row in
                                    delete(section: groupIndex, row: row)
                                }
                            }
                            .listRowBackground(LinearGradient(colors: [.gray.opacity(0.2), .gray.opacity(0.4)], startPoint: .leading, endPoint: .trailing))

                        }
                        
                        
                    }
                    
                    .listStyle(InsetGroupedListStyle())
                    
                }
                
                if items.count == 0 && searchingFor.isEmpty{
                    VStack(spacing: 20) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .shadow(radius: 10)
                        HStack{
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .font(.system(size: 35))
                            VStack(alignment: .leading) {
                                Text("Your items will appear here!")
                                    .bold()
                                Text("Tap Add item to get started")
                            }
                        }
                    }
                }
                else if results.count == 0{
                    HStack{
                        Image(systemName: "xmark")
                            .font(.system(size: 35))
                        VStack(alignment: .leading) {
                            Text("There are no items that match your search :(")
                                .font(.caption.bold())
                            Text("You better add some more stuff!")
                                .font(.caption)
                        }
                    }.padding(.top, 50)
                }
            }
            .navigationTitle("Notebook")
            .navigationBarTitleDisplayMode(.inline)
            
            
        }
        .searchable(text: $searchingFor, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search items")
    }
    func delete(section: Int, row: IndexSet) {
        let currentResults = self.results
        let deleteIndex = row[row.startIndex]
        items.remove(at: items.firstIndex(of: currentResults[section][deleteIndex])!)
        }
    
    var results: [[listItem]] {
        var temp: [listItem] = []
        if searchingFor.isEmpty && lockedTags.isEmpty{
            temp = items
        }
        else if lockedTags.isEmpty{
            temp = items.filter{$0.matchesSearch(searchTerm: searchingFor)}
        }
        else if searchingFor.isEmpty{
            temp = items.filter{$0.matchesTags(matchTags: lockedTags)}
        }
        else{
            temp = items.filter{$0.matchesSearch(searchTerm: searchingFor) && $0.matchesTags(matchTags: lockedTags)}
        }
//        temp = temp.reversed()
        switch groupBy {
        case .none:
            return temp.isEmpty ? [] : [temp]
        case .category:
//            showingTags = []
            var temp2: [[listItem]] = []
            for tag in Tag.allTags{
                let matches: [listItem] = temp.filter{!($0.tags.filter({$0.name == tag.name}).isEmpty)}
                if !matches.isEmpty{
//                    showingTags.append(tag)
//                    print(showingTags)
                    temp2.append(matches)
                }
            }
            return temp2
        case .type:
            var temp3: [[listItem]] = []
            for type in contentType.allCases{
                let matches2: [listItem] = temp.filter{$0.selectedContentType == type}
                if !matches2.isEmpty{
                    temp3.append(matches2)
                }
            }
            return temp3
        }
    }
    
    var showingTags: [Tag]{
        var temp: [Tag] = []
        for tag in Tag.allTags{
            var isRepresented: Bool = false
            for item in items{
                var isShowing: Bool = false
                for group in results{
                    if group.contains(item){
                        isShowing = true
                        break
                    }
                }
                if isShowing && !item.tags.filter({$0.name == tag.name}).isEmpty{
                    isRepresented = true
                    break
                }
            }
            if isRepresented{
                temp.append(tag)
            }
        }
        return temp
    }
    
    var showingItems: [listItem]{
        let currentResults = results
        var temp: [listItem] = []
        for group in currentResults{
            for item in group{
                temp.append(item)
            }
        }
        return temp
    }
    
    enum GroupingType: String, CaseIterable{
        
        case none
        case category
        case type
        
        var description: String{
            switch self{
            case .none: return "None"
            case .category: return "Category"
            case .type: return "Type"
            }
        }
    }
}

struct addView: View{
    
    @Binding var newItem: listItem
    @State var contentInt: Int = 0
    @State var contentDate: Date = .now
    @State var newAlias: String = ""
    @Binding var selectedTags: [Bool]
    var body: some View{
        VStack {
            Label("Add new item", systemImage: "plus.square.on.square")
                .font(.largeTitle.bold())
            HStack{
                VStack(alignment: .leading){
                    Text(newItem.allKeywords[0].isEmpty ? "?" : newItem.allKeywords[0])
                    Text(newItem.contentToString.isEmpty ? "?" : newItem.contentToString).bold()
                }
//                Image(systemName: "return.left")
                Image(systemName: newItem.isReady ? "checkmark.circle" : "xmark.circle")
                    .foregroundColor(newItem.isReady ? .green : .orange)
            }
            Form{
                
                Section(header: Text("Content Type")){
                Picker("content type", selection: $newItem.selectedContentType){
                    ForEach(contentType.allCases, id: \.self){type in
                        Text(type.description).tag(type)
                    }
                }.pickerStyle(.segmented)
                    .padding(.horizontal, -12)
                }
                
                Section{
                    switch newItem.selectedContentType {
                        case .string:
                        TextField("Add content", text: $newItem.contentText)
                        case .number:
//                        HStack{
//                            TextField("Add content", text: $contentInt)
//                                .keyboardType(.numberPad)
                        Stepper(String(newItem.contentInt), value: $newItem.contentInt)
                                .padding(.trailing, -12)
//                        }
                        case .date:
                        DatePicker(selection: $newItem.contentDate, displayedComponents: .date){
                            Text("Set Date")
                        }
                            .padding(.trailing, -12)
                        default:
                        TextField("Add content", text: $newItem.contentText)
                    }
                }
                
                Section{
                    TextField("Add description", text: $newItem.allKeywords[0])
                    if !newItem.allKeywords[0].isEmpty && newItem.allKeywords.count > 1{
                        ForEach(1...newItem.allKeywords.count-1, id: \.self){ i in
                            TextField("Edit alias", text: $newItem.allKeywords[i])
                        }
                    }
                    if !newItem.allKeywords[0].isEmpty{
                        TextField("Add alias", text: $newAlias)
                            .onSubmit {
                                if !newAlias.isEmpty{
                                    newItem.allKeywords.append(newAlias)
                                newAlias = ""
                                }
                            }
                    }
                }
                
                Section(header: Text("Categories")){
                    ForEach(0...Tag.allTags.count-1, id: \.self){i in
                        Button(action:{
                            selectedTags[i].toggle()
                        }) {
                            HStack {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .symbolVariant(selectedTags[i] ? .fill : .none)
                                    .foregroundColor(selectedTags[i] ? Tag.allTags[i].color : .primary)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.body.bold())
                                            .imageScale(.small)
                                            .foregroundColor(.white)
                                            .opacity(selectedTags[i] ? 1 : 0)
                                    )
                                Text(Tag.allTags[i].name)
                            }.foregroundColor(.primary)
                        }
                    }
                }
                
            }
            .shadow(radius: 10)
            .padding()
            .animation(.default, value: newItem.allKeywords)
            
            
        }.edgesIgnoringSafeArea(.bottom)
    }
}

struct editView: View{
    
    @Binding var editItem: listItem
    @State var newAlias: String = ""
    var body: some View{
        VStack {
            Label("Edit this item", systemImage: "square.and.pencil")
                .font(.largeTitle.bold())
            HStack{
                VStack(alignment: .leading){
                    Text(editItem.allKeywords[0].isEmpty ? "?" : editItem.allKeywords[0])
                    Text(editItem.contentToString.isEmpty ? "?" : editItem.contentToString).bold()
                }
                Image(systemName: "return.left")
                Image(systemName: editItem.isReady ? "checkmark.circle" : "xmark.circle")
                    .foregroundColor(editItem.isReady ? .green : .orange)
            }
            Form{
                Section{
                    TextField("Add keyword", text: $editItem.allKeywords[0])
                    if !editItem.allKeywords[0].isEmpty && editItem.allKeywords.count > 1{
                        ForEach(1...editItem.allKeywords.count-1, id: \.self){ i in
                            TextField("Edit alias", text: $editItem.allKeywords[i])
                        }
                    }
                    if !editItem.allKeywords[0].isEmpty{
                        TextField("Add alias", text: $newAlias)
                            .onSubmit {
                                if !newAlias.isEmpty{
                                    editItem.allKeywords.append(newAlias)
                                    newAlias = ""
                                }
                            }
                    }
                }
                Section(header: Text("Content Type")){
                Picker("content type", selection: $editItem.selectedContentType){
                    ForEach(contentType.allCases, id: \.self){type in
                        Text(type.description).tag(type)
                    }
                }.pickerStyle(.segmented)
                    .padding(.horizontal, -12)
                }
                
                Section{
                    switch editItem.selectedContentType {
                        case .string:
                        TextField("Add content", text: $editItem.contentText)
                        case .number:
//                        HStack{
//                            TextField("Add content", text: $contentInt)
//                                .keyboardType(.numberPad)
                        Stepper(String(editItem.contentInt), value: $editItem.contentInt)
                                .padding(.trailing, -12)
//                        }
                        case .date:
                        DatePicker(selection: $editItem.contentDate, displayedComponents: .date){
                            Text("Set Date")
                        }
                            .padding(.trailing, -12)
                        default:
                        TextField("Add content", text: $editItem.contentText)
                    }
                }
                Section(header: Text("Tags")){
                    ForEach(Tag.allTags, id: \.self){ itag in
                        Button(action:{
                            if editItem.tags.contains(itag){
                                editItem.tags = editItem.tags.filter{$0 != itag}
                            }
                            else{
                                editItem.tags.append(itag)
                            }
                        }) {
                            HStack {
                                Image(systemName: "circle")
                                    .imageScale(.large)
                                    .symbolVariant(editItem.tags.contains(itag) ? .fill : .none)
                                    .foregroundColor(editItem.tags.contains(itag) ? itag.color : .primary)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.body.bold())
                                            .imageScale(.small)
                                            .foregroundColor(.white)
                                            .opacity(editItem.tags.contains(itag) ? 1 : 0)
                                    )
                                Text(itag.name)
                            }.foregroundColor(.primary)
                        }
                    }
                }
            }
            .shadow(radius: 10)
            .padding()
            .animation(.default, value: editItem.allKeywords)
            
            
        }.edgesIgnoringSafeArea(.bottom)
    }
}

struct contentType: Hashable, Codable{
    var description: String
    var defaultContent: String
}

extension contentType{
    public static let string: contentType = .init(description: "Normal", defaultContent: "")
    public static let number: contentType = .init(description: "Number", defaultContent: "0")
    public static let date: contentType = .init(description: "Date", defaultContent: dateToString(date: .now))
    public static let allCases: [contentType] = [.string, .number, .date]
}

struct listItem: Hashable, Codable{
    var allKeywords: [String]
    var selectedContentType: contentType
    var contentText: String
    var contentInt: Int
    var contentDate: Date
    var tags: [Tag]
    init(){
        self.contentText = ""
        self.contentInt = 0
        self.contentDate = .now
        self.allKeywords = [""]
        self.selectedContentType = .string
        self.tags = []
    }
    var isReady: Bool{
        if selectedContentType == .string{
            return !contentText.isEmpty
        }
        return true
    }
    var contentToString: String{
        switch selectedContentType{
            case .string:
                return contentText
            case .number:
                return String(contentInt)
            case .date:
                return dateToString(date: contentDate)
            default:
                return contentText
        }
    }
//    func matchesTags(matchTags: [Tag]) -> Bool{
//        for itag in matchTags{
//            if self.tags.filter({$0.name == itag.name}).isEmpty{
//                return false
//            }
//        }
//        return true
//    }
    
    func matchesTags(matchTags: [Tag]) -> Bool{
            for itag in matchTags{
                if !self.tags.filter({$0.name == itag.name}).isEmpty{
                    return true
                }
            }
            return false
        }
    
    func matchesSearch(searchTerm: String) -> Bool{
        for kwrd in self.allKeywords{
            if kwrd.lowercased().contains(searchTerm.lowercased()){
                return true
            }
        }
        return self.contentToString.lowercased().contains(searchTerm.lowercased())
    }
    
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}


struct Tag: Hashable, Codable{
    var name: String
    var symbol: String
    var color: Color
}

extension Tag{
    public static let personal: Tag = .init(name: "personal", symbol: "person.fill", color: .red)
    public static let work: Tag = .init(name: "work", symbol: "building.fill", color: .orange)
    public static let planning: Tag = .init(name: "planning", symbol: "text.append", color: .yellow)
    public static let pastEvents: Tag = .init(name: "past events", symbol: "text.insert", color: .green)
    public static let contactInformation: Tag = .init(name: "contact information", symbol: "person.text.rectangle.fill", color: .cyan)
    public static let birthdays: Tag = .init(name: "birthdays", symbol: "calendar", color: .blue)
    public static let toDo: Tag = .init(name: "to-do", symbol: "checklist", color: .purple)
    public static let random: Tag = .init(name: "random", symbol: "lightbulb.fill", color: .pink)
    public static let allTags: [Tag] = [.personal, .work, .planning, .pastEvents, .contactInformation, .birthdays, .toDo, .random]
}

func dateToString(date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, YYYY"
    return dateFormatter.string(from: date)
}
func stringToDate(string: String) -> Date{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, YYYY"
    return dateFormatter.date(from: string) ?? .now
}

func listToTags(list: [Bool]) -> [Tag]{
    var temp: [Tag] = []
    for i in 0...7 {
        if list[i]{
            temp.append(Tag.allTags[i])
        }
    }
    return temp
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
            
            
    }
}

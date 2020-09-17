//
//  Scripts.swift
//  quicklook
//
//  Created by Toxicspu on 4/6/20.
//  Copyright © 2020 developer. All rights reserved.
//https://www.youtube.com/watch?v=IHx53KJnL-o

import Foundation
import SwiftUI


struct Scripts: View {
    @EnvironmentObject var controlCenter: ControlCenter
    @ObservedObject var viewModel = Defaults()
    @State var scripts: [Responses.Scripts.Results] = []
    @State private var firstLoader:Bool = true
    @State private var searchTerm:String = ""
    
    
    func removeItems(at offsets: IndexSet){
     
        if searchTerm != "" {
            let filteredScripts = scripts.filter {
                self.searchTerm.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(self.searchTerm)}
            let itemIndex:Int = offsets.first!
            print(filteredScripts[itemIndex].name)
            print(filteredScripts[itemIndex].jamfId )
            print("Deleting "+filteredScripts[itemIndex].name)
            ScriptsAPI().deleteScript(defaults: self.viewModel, id: filteredScripts[itemIndex].jamfId.description)
            self.scripts = filteredScripts
            self.scripts.remove(atOffsets: offsets)
            ScriptsAPI().getScripts(defaults: self.viewModel) { (scripts) in
                self.scripts = scripts}
        } else {
            let itemIndex:Int = offsets.first!
            print(self.scripts[itemIndex].name)
            print(self.scripts[itemIndex].jamfId)
            print("Deleting "+self.scripts[itemIndex].name)
            ScriptsAPI().deleteScript(defaults: self.viewModel, id: String(self.scripts[itemIndex].jamfId))
            self.scripts.remove(atOffsets: offsets)
        }
    }
    
    
    var body: some View {
        VStack{
            SearchBar(text:$searchTerm)
            List{
                
                ForEach(scripts.filter {
                    self.searchTerm.isEmpty ? true : $0.name.localizedCaseInsensitiveContains(self.searchTerm)
                }) { script in
                    NavigationLink(destination: DownloadScripts().onAppear{
                        
                        self.controlCenter.scriptId = String(script.jamfId)
                        self.controlCenter.scriptName = script.name
                        
                        ScriptsAPI().downloadScript(defaults:self.viewModel, id:String(script.jamfId), control:self.controlCenter)})
                    {Text(script.name)}
                    
                }.onDelete(perform: removeItems)
                
            }
                
       
        }
        .navigationBarTitle("Scripts")
        .onAppear {if self.firstLoader {
                print("Jet")
                   ScriptsAPI().getScripts(defaults:self.viewModel) { (scripts) in
                   self.scripts = scripts
                   self.firstLoader = false
                   print("Scripts Appeared")
                   }
                   }
               }
    }
    
    
    struct DownloadScripts: View {
        @EnvironmentObject var controlCenter: ControlCenter
         let pasteboard = UIPasteboard.general
        func initShareData(){
            sharedSubject = self.controlCenter.scriptName
            sharedItem = self.controlCenter.scriptContents
        }
        
        var body: some View{
            ScrollView{
                VStack(alignment: .center){
                Text("Press to copy, paste into your favorite editor!!!").font(.system(size: 10)) .italic().bold()
               //
                }
                Button(action: {
                    self.pasteboard.string = self.controlCenter.scriptContents
                })
                {VStack(alignment:.leading){
                        Text(self.controlCenter.scriptContents).font(.custom("SFMono-Regular", size: 12))
                            .foregroundColor(.primary)
                            .padding(.all, 10).background(Color(.gray).opacity(0.25)).cornerRadius(10)
                            .padding(.all, 10)
                  
                    
                    }
                 
                }
                
                VStack(alignment: .center){
                    Text("Navigate to Main Menu > Computers\nSelect a computer to run the script.\nPress Push Script!!!").font(.system(size: 12)).italic().bold().multilineTextAlignment(.center)
                                 }
                HStack{
                    Spacer()
                }
                
          
                
                
            }
            .navigationBarTitle(self.controlCenter.scriptName)
            .navigationBarItems(trailing: Button(action: {self.initShareData()
                Share().showView()}){Image(systemName:"square.and.arrow.up").font(.body)
                    .padding(.all, 10)})
        }
    }
}

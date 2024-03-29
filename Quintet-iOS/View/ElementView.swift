//
//  ElementView.swift
//  Quintet-iOS
//
//  Created by 옥재은 on 2023/11/10.
//

import SwiftUI

//요소별 위에 5개 카드
struct RecordElementView : View {
    @Binding var currentDate: Date
    @State var recordIndex: recordElement
    @State private var isShowPopup = false
    @StateObject private var viewModel = DateViewModel()
    @State var currentMonth: Int = 0
    @ObservedObject private var coreDataViewModel = CoreDataViewModel()
    @ObservedObject private var recordLoginViewModel = RecordLoginViewModel()
    private let hasLogin = /*KeyChainManager.hasKeychain(forkey: .accessToken)*/false
    @State private var healthRecords: [RecordMetaData] = []
    @State private var workRecords: [RecordMetaData] = []
    @State private var relationshipRecords: [RecordMetaData] = []
    @State private var assetRecords: [RecordMetaData] = []
    @State private var familyRecords: [RecordMetaData] = []

    
    func displayRecords(for recordElement: recordElement, records: [RecordMetaData]) -> some View {
        VStack {
            Divider()
                .padding(.horizontal)
            Button(action: {
                isShowPopup = true
            }) {
                HStack {
                    viewModel.yearMonthButtonTextRecordVer
                        .foregroundColor(Color.black)
                    Image(systemName: isShowPopup ? "chevron.up" : "chevron.down")
                        .foregroundColor(.black)
                        .font(.system(size: 15))
                }
                .padding(.top, 25)
                .padding(.trailing, 180)
            }
            .sheet(isPresented: $isShowPopup) {
                CalendarYearMonthPickerPopup(viewModel: viewModel, isShowPopup: $isShowPopup)
                    .frame(width: 300, height: 400)
                    .background(BackgroundClearView())
                    .ignoresSafeArea()
            }
            
            if viewModel.selectedYear == Calendar.current.component(.year, from: currentDate) &&
                viewModel.selectedMonth == Calendar.current.component(.month, from: currentDate) {
                ForEach(records) { metaData in
                    ForEach(metaData.records) { record in
                        recordCard(icon: record.icon, title: record.title, subtitle: record.subtitle)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Button(action: {
                    self.recordIndex = .work
                }) {
                    ElementCard(icon: "pencil", title: "일", size: 34, space: 55, fC: recordIndex == .work ? Color.white : Color("DarkGray"), bC: recordIndex == .work ? Color("DarkQ") : Color.white)
                }
                
                Button(action: {
                    self.recordIndex = .health
                }) {
                    ElementCard(icon: "cross.circle.fill", title: "건강", size: 30, space: 30, fC: recordIndex == .health ? Color.white : Color("DarkGray"), bC: recordIndex == .health ? Color("DarkQ") : Color.white)
                }
            }
            
            HStack(spacing: 6) {
                Button(action: {
                    self.recordIndex = .relation
                }) {
                    ElementCard(icon: "person.3.fill", title: "관계", size: 25, space: 25, fC: recordIndex == .relation ? Color.white : Color("DarkGray"), bC: recordIndex == .relation ? Color("DarkQ") : Color.white)
                }
                
                Button(action: {
                    self.recordIndex = .family
                }) {
                    ElementCard(icon: "heart.fill", title: "가족", size: 30, space: 30, fC: recordIndex == .family ? Color.white : Color("DarkGray"), bC: recordIndex == .family ? Color("DarkQ") : Color.white)
                }
            }
            
            HStack(spacing: 230) {
                Button(action: {
                    self.recordIndex = .money
                }) {
                    Text("자산")
                        .fontWeight(.bold)
                        .font(.system(size: 23))
                        .foregroundColor(recordIndex == .money ? .white : Color("DarkGray"))
                        .offset(x: -113)
                    
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(recordIndex == .money ? .white : Color("DarkGray"))
                        .offset(x: 106)
                }
            }
            .frame(width: 310, height: 50)
            .padding(20)
            .background(recordIndex == .money ? Color("DarkQ") : Color.white)
            .cornerRadius(20)
        }
        .onAppear {
            loadRecords()
        }
        .onChange(of: currentMonth) { newValue in
            viewModel.selectedYear = Calendar.current.component(.year, from: currentDate)
            viewModel.selectedMonth = Calendar.current.component(.month, from: currentDate)
            currentDate = getCurrentMonth()
            loadRecords()
        }
        

            switch recordIndex {
            case .health:
                displayRecords(for: recordIndex, records: healthRecords)
            case .work:
                displayRecords(for: recordIndex, records: workRecords)
            case .money:
                displayRecords(for: recordIndex, records: assetRecords)
            case .relation:
                displayRecords(for: recordIndex, records: relationshipRecords)
            case .family:
                displayRecords(for: recordIndex, records: familyRecords)
            case .None:
                EmptyView()
            }
    }
    
    func loadRecords() {
        if hasLogin {
            recordLoginViewModel.getRecord(for: "건강", year: viewModel.selectedYear, month: viewModel.selectedMonth) { processedData in
                DispatchQueue.main.async {
                    self.healthRecords = processedData
                }
            }
            recordLoginViewModel.getRecord(for: "일", year: viewModel.selectedYear, month: viewModel.selectedMonth) { processedData in
                DispatchQueue.main.async {
                    self.workRecords = processedData
                }
            }
            recordLoginViewModel.getRecord(for: "관계", year: viewModel.selectedYear, month: viewModel.selectedMonth) { processedData in
                DispatchQueue.main.async {
                    self.relationshipRecords = processedData
                }
            }
            recordLoginViewModel.getRecord(for: "자산", year: viewModel.selectedYear, month: viewModel.selectedMonth) { processedData in
                DispatchQueue.main.async {
                    self.assetRecords = processedData
                }
            }
            recordLoginViewModel.getRecord(for: "가족", year: viewModel.selectedYear, month: viewModel.selectedMonth) { processedData in
                DispatchQueue.main.async {
                    self.familyRecords = processedData
                }
            }
        } else {
            coreDataViewModel.getHealthRecords(for: viewModel.selectedYear, month: viewModel.selectedMonth) { processedData in
                DispatchQueue.main.async {
                    self.healthRecords = processedData
                }
            }
            coreDataViewModel.getWorkRecords(for: viewModel.selectedYear, month: viewModel.selectedMonth) { processedData in
                DispatchQueue.main.async {
                    self.workRecords = processedData
                }
            }
            coreDataViewModel.getRelationshipRecords(for: viewModel.selectedYear, month: viewModel.selectedMonth) { processedData in
                DispatchQueue.main.async {
                    self.relationshipRecords = processedData
                }
            }
            coreDataViewModel.getAssetRecords(for: viewModel.selectedYear, month: viewModel.selectedMonth) { processedData in
                DispatchQueue.main.async {
                    self.assetRecords = processedData
                }
            }
            coreDataViewModel.getFamilyRecords(for: viewModel.selectedYear, month: viewModel.selectedMonth) { processedData in
                DispatchQueue.main.async {
                    self.familyRecords = processedData
                }
            }
            
            
        }
    }
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else {
            return Date()
        }
        return currentMonth
    }
}

//요소별 개별 카드
struct ElementCard : View {
        var icon : String
        var title : String
        var size : Int
        var space : Int
        var fC : Color
        var bC : Color
        
        var body: some View {
            
            HStack(spacing: CGFloat(space)) {
                
                Text(title)
                    .fontWeight(.bold)
                    .font(.system(size: 23))
                    .foregroundColor(fC)
                Image(systemName: icon)
                    .font(.system(size: CGFloat(size)))
                    .foregroundColor(fC)
                    .fontWeight(.bold)
                
            }
            .frame(width: 135, height: 50)
            .padding(18)
            .background(bC)
            .cornerRadius(20)
            
        }
    }

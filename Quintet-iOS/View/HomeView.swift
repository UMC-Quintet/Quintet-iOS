//
//  ContentView.swift
//  Quintet-iOS
//
//  Created by Phil on 2023/07/09.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var loginViewModel: LoginViewModel
    @EnvironmentObject private var coreDataViewModel: CoreDataViewModel
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var dateViewModel = DateViewModel()
    
    @AppStorage("_isFirstLaunching") var isFirstLaunching: Bool = true
    var body: some View {
        NavigationView{
            VStack{
                ScrollView {
                    VStack{
                        HStack{
                            Text(viewModel.getTodayString())
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .padding(.leading, 5)
                            Spacer()
                        }
                        Divider()
                            .frame(height: 0.6)
                            .background(Color("LightGray"))
                            .padding(.top)
                        // MARK: - 요일 Section
                        HStack{
                            ForEach(0..<7, id: \.self) { index in
                                WeekCellView(viewModel: viewModel,date: viewModel.getDate(index: index), quintetData: viewModel.getSelectDayData(date: viewModel.getDate(index: index)), is_selected: viewModel.getDate(index: index) == viewModel.selectDay).onTapGesture {
                                    viewModel.setSelectDay(index: index)
                                }
                            }
                        }
                        .padding()
                        
                        // MARK: - 선택한 날짜에 퀸텟 기록이 있으면 보여주고, 없으면 없다는 메세지를 보여줌
                        if let quintetData = viewModel.getSelectDayData(date: viewModel.selectDay){
                            HappinessView(quintetData: quintetData).padding(.top, 10)
                            Divider()
                                .frame(height: 0.6)
                                .background(Color("LightGray"))
                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                        }
                        else{
                            HStack{
                                Text("퀸텟체크 기록이 없습니다.").padding(.leading, 20)
                                Spacer()
                            }.padding(EdgeInsets(top: 20, leading: 0, bottom: 25, trailing: 0))
                        }
                        
                        
                        // MARK: - 오늘의 퀸텟 체크 Section
                        ZStack{
                            NavigationLink(destination: QuintetCheckView()){
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.white)
                            }
                            HStack{
                                Text("오늘의 \n퀸텟체크")
                                    .font(.system(size: 28))
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 30)
                                Spacer()
                                VStack{
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .tint(.black)
                                        .font(.title)
                                }
                                .padding(.horizontal, 40)
                                .padding(.vertical, 30)
                            }
                        }.onAppear{
                            print("update QuintetData")
                            viewModel.updateValuesFromCoreData(startDate: viewModel.startDate, endDate: viewModel.endDate)
                        }
                        .padding(.vertical)
                        
                        // MARK: - 분석확인, 기록확인 Section
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.white)
                            VStack{
                                ZStack{
                                    NavigationLink(destination: {StatisticsView()}){
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                    }
                                    HStack(alignment: .center){
                                        Text("분석 확인하기")
                                            .fontWeight(.semibold)
                                            .font(.system(size: 18)).padding()
                                        
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .tint(.black)
                                            .font(.title)
                                            .padding()
                                    }.padding(.horizontal)
                                }
                                
                                Divider().frame(height: 2.5)
                                    .background(Color("LightGray2"))
                                    .padding(.horizontal)
                                ZStack{
                                    NavigationLink(destination: RecordView()){
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                    }
                                    HStack(alignment: .center){
                                        Text("기록 확인하기")
                                            .fontWeight(.semibold)
                                            .font(.system(size: 18))
                                            .padding()
                                        
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .tint(.black)
                                            .font(.title)
                                            .padding()
                                        
                                    }.padding(.horizontal)
                                }
                            }.padding(.vertical, 10)
                        }.padding(.vertical)
                        
                        // MARK: - 추천 영상 Section
                        HStack{
                            Text("추천 영상으로\n행복을 챙겨요")
                                .fontWeight(.semibold)
                                .font(.system(size: 30))
                                .padding()
                            Spacer()
                        }.padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
                        
                        VStack{
                            HStack{
                                //각 영상 cell을 등록
                                VideoCellView(videoURL: "https://youtu.be/Y4r_rfQ09Vg", videoTitle: "건강한 삶을 위한 규칙적인 식습관", thumbnail: "video1")
                                    .padding(.leading, 7)
                                Spacer()
                                    .frame(width: 7)
                                VideoCellView(videoURL: "https://www.youtube.com/watch?v=9cxwIX9YBeY", videoTitle: "인간관계에서 편해지는 법", thumbnail: "video2")
                                    .padding(.trailing, 7)
                            }.padding(.bottom, 7)
                            VideoCellView(videoURL: "https://youtu.be/kQZSeJXq7lE", videoTitle: "월급의 몇 %를 저축하고 있나요?", thumbnail: "video3")
                                .padding(.horizontal, 7)
                        }
                    }
                    .padding(20)
                }
            }
            .background(Color("Background"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: MenuView().environmentObject(loginViewModel)) {
                        Image(systemName: "line.3.horizontal").padding()
                            .tint(.black)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isFirstLaunching) {
            OnboardingTabView(isFirstLaunching: $isFirstLaunching)
        }
    }
}


// MARK: - 요일 cell
struct WeekCellView: View{
    let viewModel: HomeViewModel
    let date : Date
    let quintetData : QuintetData?
    var is_selected: Bool //해당 셀이 선택 되었는지
    
    var body: some View{
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(getForegroundColor())
                .frame(width: 40, height: 90)
            VStack{
                Text(viewModel.getWeekDayString(date: date))
                    .foregroundColor(getTextColor())
                    .padding(.bottom)
                    .fontWeight(.light)
                Text(viewModel.getDayString(date: date))
                    .foregroundColor(getTextColor())
                    .fontWeight(.semibold)
            }
        }
    }
    
    //요일 박스의 색을 결정한다. 선택되어 있다면 파란색, 아니라면 기록 유무에 따라 색을 결정
    private func getForegroundColor() -> Color {
        if is_selected{
            return Color("DarkQ")
        } else {
            if(viewModel.isSameDay(date1: date, date2: Date())) { //오늘 날짜일 경우
                return Color("DarkGray")
            }
            else {
                if quintetData != nil{
                    return Color("LightGray2")
                }else{return .clear}
            }
        }
    }
    
    //요일 박스의 글자 색을 결정한다. (흰색 또는 검은색)
    private func getTextColor() -> Color {
        if is_selected || viewModel.isSameDay(date1: date, date2: Date()){
            return Color("White")
        } else {
            return Color("Black")
        }
    }
    
}

// MARK: - 일, 건강, 가족, 관계, 자산 5가지 퀸텟 지수를 나타내는 cell
struct HappinessCell: View{
    let type: String
    let value: Int
    
    var body: some View{
        HStack{
            Text(type)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            switch value{
            case 0:
                Image("XOn")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 22, maxHeight: 22)
            case 1:
                Image("TriangleOn")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 22, maxHeight: 22)
            default:
                Image("CircleOn")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 22, maxHeight: 22)
            }
        }
    }
}

// MARK: - 5가지 퀸텟 지수 Cell을 모아둔 view. 퀸텟 체크 기록이 있어야 나타난다.
struct HappinessView: View{
    let quintetData : QuintetData
    
    var body: some View{
        HStack{
            HappinessCell(type: "일", value: Int(quintetData.workPoint))
            Spacer()
            HappinessCell(type: "건강", value: Int(quintetData.healthPoint))
            Spacer()
            HappinessCell(type: "가족", value: Int(quintetData.familyPoint))
            Spacer()
            HappinessCell(type: "관계", value: Int(quintetData.relationshipPoint))
            Spacer()
            HappinessCell(type: "자산", value: Int(quintetData.assetPoint))
        }.padding(.horizontal)
    }
}


// MARK: - video cell
struct VideoCellView: View{
    let videoURL: String
    let videoTitle: String
    let thumbnail: String
    
    var body: some View{
        ZStack{
            Button {
                print("video cell tapped")
                UIApplication.shared.open(URL(string: videoURL)!) //임시 주소
            } label: {
                Image(thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            VStack{
                Spacer()
                HStack{
                    Text(videoTitle)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding()
                    Spacer()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

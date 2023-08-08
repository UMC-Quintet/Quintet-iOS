//
//  LoginView.swift
//  Quintet-iOS
//
//  Created by 이동현 on 2023/08/03.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        NavigationView{
            ZStack{
                Color("Background").ignoresSafeArea(.all)
                VStack{
                    Spacer()
                    Image("Quintet_main")
                    
                    Spacer()
                    
                    //MARK: 회원 로그인 버튼 모음
                    VStack{
                        Button {
                            print("kakao loginBtn Tapped")
                        } label: {
                            Image("Kakao_login")
                        }
                        
                        Button {
                            print("apple loginBtn Tapped")
                        } label: {
                            Image("Apple_login")
                        }
                        
                        Button {
                            print("google loginBtn Tapped")
                        } label: {
                            Image("Google_login")
                        }
                    }.padding(.vertical, 30)
                    
                    //MARK: 비회원 로그인 버튼
                    NavigationLink(destination: {
                        HomeView()
                    }){
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("DarkGray"))
                                .frame(width: 345, height: 52)
                                .overlay(Text("비회원으로 로그인 하기")
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                )
                            
                        }
                    }.padding(.bottom, 20)
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

import SwiftUI
import AppViewModel

struct CameraAuthorizedView: ContentView {
 
    let viewData: CameraContentViewData
    let viewAction: CameraContentAction


    var body: some View {
        ZStack {
            
            if viewData.cameraData.showFilter {
                CameraMetalViewer(viewAction: viewAction.cameraAction)
            }else if viewData.cameraData.showMultiCam {
                    DualCameraViewer(viewAction: viewAction.cameraAction)
                }else {
                    CameraFeedViewer(viewAction: viewAction.cameraAction)
                }
    
            VStack() {
                HStack {
                    Spacer()
                    CameraActionBar(onAction: viewAction.cameraAction)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                Spacer()

                if viewData.cameraData.showFilter {
                    FilterListView(viewData: viewData.filterData, onAction: viewAction.filterAction)
                        .padding(.bottom)
                }
                
                HStack {
                    Spacer()
                    CameraCaptureControl(viewData: viewData.cameraData, viewAction: viewAction.cameraAction)
                        .padding(.bottom, 16)
                    Spacer()
                }
            }
        }
    }
}


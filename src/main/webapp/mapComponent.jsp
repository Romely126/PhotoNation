<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!-- OpenStreetMap 컴포넌트 -->
<div id="mapContainer" style="height: 600px; border-radius: 10px; position: relative;">
    <div id="photoNationMapDiv" style="height: 100%; width: 100%; border-radius: 10px;"></div>
</div>

<script>
// 지도 초기화 및 관련 기능들
(function() {
    console.log('mapComponent 스크립트 시작');
    
    // 기존 지도가 있다면 제거
    if (window.photoNationMap) {
        console.log('기존 지도 제거');
        window.photoNationMap.remove();
        window.photoNationMap = null;
    }
    
    // DOM이 준비될 때까지 대기
    function initializeMap() {
        try {
            console.log('지도 초기화 시작');
            
            // 지도 div가 존재하는지 확인
            const mapDiv = document.getElementById('photoNationMapDiv');
            if (!mapDiv) {
                console.error('지도 div를 찾을 수 없습니다');
                return;
            }
            
            // Leaflet이 로드되었는지 확인
            if (typeof L === 'undefined') {
                console.error('Leaflet 라이브러리가 로드되지 않았습니다');
                return;
            }
            
            // OpenStreetMap 초기화 (서울 중심)
            window.photoNationMap = L.map('photoNationMapDiv', {
                center: [37.5665, 126.9780],
                zoom: 13,
                zoomControl: true,
                attributionControl: true
            });
            
            // 타일 레이어 추가
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
                maxZoom: 19
            }).addTo(window.photoNationMap);
            
            console.log('지도 초기화 완료');
            
            // 서울 주요 출사지 마커들 추가
            addPhotoSpots();
            
            // 지도 로드 완료 후 크기 재조정
            setTimeout(function() {
                if (window.photoNationMap) {
                    window.photoNationMap.invalidateSize();
                    console.log('지도 크기 재조정 완료');
                }
            }, 200);
            
        } catch (error) {
            console.error('지도 초기화 중 오류 발생:', error);
            
            // 오류 메시지 표시
            const mapDiv = document.getElementById('photoNationMapDiv');
            if (mapDiv) {
                mapDiv.innerHTML = `
                    <div style="height: 100%; display: flex; align-items: center; justify-content: center; 
                                background-color: #f8f9fa; border-radius: 10px; flex-direction: column;">
                        <i class="fas fa-map-marked-alt fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">지도를 불러올 수 없습니다</h5>
                        <p class="text-muted mb-3">잠시 후 다시 시도해주세요</p>
                        <button class="btn btn-primary btn-sm" onclick="location.reload()">
                            <i class="fas fa-redo"></i> 새로고침
                        </button>
                    </div>
                `;
            }
        }
    }
    
    // 출사지 마커 추가 함수
    function addPhotoSpots() {
        const photoSpots = [
            {
                lat: 37.5665, lng: 126.9780,
                title: "서울 중심가",
                description: "도심 야경 촬영 명소"
            },
            {
                lat: 37.5665, lng: 126.9784,
                title: "청계천",
                description: "도심 속 자연과 조명이 어우러진 곳"
            },
            {
                lat: 37.5794, lng: 126.9770,
                title: "경복궁",
                description: "전통 건축물과 한복 촬영 명소"
            },
            {
                lat: 37.5663, lng: 126.9779,
                title: "남산서울타워",
                description: "서울 전경을 한눈에 볼 수 있는 곳"
            },
            {
                lat: 37.5172, lng: 127.0473,
                title: "한강공원",
                description: "일출, 일몰 촬영의 명소"
            },
            {
                lat: 37.5840, lng: 127.0026,
                title: "동대문디자인플라자",
                description: "현대적 건축물과 야경 촬영지"
            }
        ];
        
        photoSpots.forEach(function(spot, index) {
            const marker = L.marker([spot.lat, spot.lng])
                .addTo(window.photoNationMap);
                
            const popupContent = `
                <div style="text-align: center; min-width: 200px;">
                    <h6 style="margin: 0 0 8px 0; color: #333;">${spot.title}</h6>
                    <p style="margin: 0 0 10px 0; color: #666; font-size: 0.9em;">${spot.description}</p>
                    <button class="btn btn-sm btn-primary" onclick="alert('출사 정보 상세보기 기능은 추후 업데이트 예정입니다.')">
                        <i class="fas fa-camera"></i> 상세보기
                    </button>
                </div>
            `;
            
            marker.bindPopup(popupContent);
            
            // 첫 번째 마커는 자동으로 팝업 열기
            if (index === 0) {
                marker.openPopup();
            }
        });
    }
    
    // 지도 초기화 실행
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initializeMap);
    } else {
        // DOM이 이미 로드된 경우 약간의 지연 후 실행
        setTimeout(initializeMap, 100);
    }
})();

// 지도 크기 재조정 함수 (외부에서 호출 가능)
window.resizeMap = function() {
    console.log('resizeMap 함수 호출');
    if (window.photoNationMap) {
        try {
            window.photoNationMap.invalidateSize();
            console.log('지도 크기 재조정 완료');
        } catch (error) {
            console.error('지도 크기 재조정 중 오류:', error);
        }
    } else {
        console.warn('지도 객체가 존재하지 않습니다');
    }
};

// 지도 중심 이동 함수
window.moveToLocation = function(lat, lng, zoom) {
    zoom = zoom || 15;
    if (window.photoNationMap) {
        window.photoNationMap.setView([lat, lng], zoom);
    }
};

// 현재 위치로 이동 함수
window.moveToCurrentLocation = function() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
            const lat = position.coords.latitude;
            const lng = position.coords.longitude;
            
            if (window.photoNationMap) {
                window.photoNationMap.setView([lat, lng], 15);
                
                L.marker([lat, lng])
                    .addTo(window.photoNationMap)
                    .bindPopup('현재 위치')
                    .openPopup();
            }
        }, function(error) {
            console.error('위치 정보를 가져올 수 없습니다:', error);
            alert('위치 정보를 가져올 수 없습니다. 브라우저 설정을 확인해주세요.');
        });
    } else {
        alert('이 브라우저는 위치 서비스를 지원하지 않습니다.');
    }
};

console.log('mapComponent 스크립트 완료');
</script>
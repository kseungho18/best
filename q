<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>주차 관리 시스템</title>
    <style>
        body {
    font-family: Arial, sans-serif;
    text-align: center;
    margin: 0;
    padding: 0;
}

.parking-container {
    position: relative;
    width: 100%;
    max-width: 900px;
    height: 80vh; /* 모바일 회전 대응 */
    max-height: 600px; /* PC 기준 최대 높이 */
    margin: auto;
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    grid-template-rows: repeat(18, 1fr);
    gap: 5px;
    background: url('도면이미지.png') no-repeat center center;
    background-size: cover;
}

.spot {
    width: 100%;
    height: 100%;
    aspect-ratio: 2 / 1;
    background-color: green;
    color: white;
    text-align: center;
    display: flex;
    justify-content: center;
    align-items: center;
    font-size: clamp(10px, 1.5vw, 14px); /* 반응형 폰트 크기 */
    font-weight: bold;
    border-radius: 10px;
    cursor: pointer;
    line-height: 1.2;
    padding: 1vw;
    text-shadow: 1px 1px 3px black;
    box-sizing: border-box;
    white-space: nowrap;
}

.occupied {
    background-color: red;
}

.empty {
    background: none;
    pointer-events: none;
}

.border-top {
    border-top: 3px solid black;
}

.border-bottom {
    border-bottom: 3px solid black;
}

.modal {
    display: none;
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background-color: rgba(0, 0, 0, 0.85);
    color: white;
    padding: 30px;
    border-radius: 10px;
    z-index: 1000;
    width: 90%;
    max-width: 450px;
    max-height: 80vh;
    overflow-y: auto;
    box-sizing: border-box;
}

.modal input {
    width: 100%;
    padding: 15px;
    margin: 5px 0;
    border: none;
    border-radius: 5px;
    font-size: 16px; /* iOS 확대 방지 */
    box-sizing: border-box;
}

.modal-buttons {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    margin-top: 10px;
}

.modal-buttons button {
    flex: 1;
    padding: 12px;
    font-size: 16px;
    border: none;
    border-radius: 5px;
    color: white;
    box-sizing: border-box;
}

.modal-buttons .remove {
    background-color: orange;
}

.modal-buttons .cancel {
    background-color: red;
}

.modal-buttons #submitBtn {
    background-color: green;
}

/* 모바일 최적화 */
@media (max-width: 600px) {
    .parking-container {
        height: 75vh;
    }

    .spot {
        font-size: clamp(8px, 3vw, 12px);
        padding: 2vw;
    }

    .modal {
        width: 90%;
        padding: 20px;
    }

    .modal input {
        padding: 12px;
        font-size: 16px;
    }

    .modal-buttons button {
        padding: 10px;
        font-size: 14px;
    }
}
    </style>
</head>
<body>
    <h2>주차 관리 시스템</h2>
    <p id="status">현재 주차된 차량: 0대 / 남은 자리: 39대</p>

    <div class="parking-container" id="parkingLot"></div>

    <div id="modal" class="modal">
        <h3>주차 정보 수정</h3>
        <input type="text" id="room" placeholder="입실 호수" inputmode="numeric">
        <input type="text" id="car" placeholder="차량 뒷번호" inputmode="numeric">
        <div class="modal-buttons">
            <button class="remove" id="removeBtn">출차</button>
            <button id="submitBtn">저장</button>
            <button class="cancel" id="cancelBtn">취소</button>
        </div>
    </div>

    <script>
        const TOTAL_SPOTS = 39;
        let parkingRecords = JSON.parse(localStorage.getItem("parkingRecords") || "{}");
        let activeSpots = [
            1, 8, 15, 22, 26, 29, 37, 42, 43, 48,
            49, 52, 54, 55, 57, 58, 60, 61, 63, 64,
            66, 67, 69, 70, 72, 73, 75, 76, 78, 79,
            81, 82, 85, 87, 91, 97, 103, 106, 108
        ];

        function updateStatus() {
            const occupiedCount = Object.keys(parkingRecords).length;
            document.getElementById("status").innerText = `현재 주차된 차량: ${occupiedCount}대 / 남은 자리: ${TOTAL_SPOTS - occupiedCount}대`;
        }

        function showModal(slot) {
            const modal = document.getElementById("modal");
            modal.style.display = "block";
            window.currentSlot = slot;

            const roomInput = document.getElementById("room");
            const carInput = document.getElementById("car");

            if (parkingRecords[slot]) {
                roomInput.value = parkingRecords[slot].room || "";
                carInput.value = parkingRecords[slot].car || "";
            } else {
                roomInput.value = "";
                carInput.value = "";
            }

            document.getElementById("submitBtn").onclick = () => {
                const room = roomInput.value;
                const car = carInput.value;
                parkingRecords[slot] = { room, car };
                const spotElement = document.getElementById(`spot-${slot}`);
                spotElement.classList.add("occupied");
                spotElement.innerText = `${room || "-"}\n${car || "-"}`;
                updateStatus();
                localStorage.setItem("parkingRecords", JSON.stringify(parkingRecords));
                modal.style.display = "none";
            };

            document.getElementById("removeBtn").onclick = () => {
                delete parkingRecords[slot];
                const spotElement = document.getElementById(`spot-${slot}`);
                spotElement.classList.remove("occupied");
                spotElement.innerText = "";
                updateStatus();
                localStorage.setItem("parkingRecords", JSON.stringify(parkingRecords));
                modal.style.display = "none";
            };

            document.getElementById("cancelBtn").onclick = () => {
                modal.style.display = "none";
            };
        }

        function toggleParking(slot) {
            showModal(slot);
        }

        function createParkingLot() {
            const lot = document.getElementById("parkingLot");

            const linesBottom = [60, 70, 69, 81, 61, 73, 85, 97, 52];
            const linesTop = [66, 76, 75, 87, 67, 79, 91, 103, 58];

            for (let i = 1; i <= 108; i++) {
                const spot = document.createElement("div");
                spot.classList.add("spot");

                if (!activeSpots.includes(i)) {
                    spot.classList.add("empty");
                } else {
                    spot.id = `spot-${i}`;
                    spot.onclick = () => toggleParking(i);

                    if (parkingRecords[i]) {
                        spot.classList.add("occupied");
                        spot.innerText = `${parkingRecords[i].room || "-"}\n${parkingRecords[i].car || "-"}`;
                    }
                }

                if (linesBottom.includes(i)) {
                    spot.classList.add("border-bottom");
                }

                if (linesTop.includes(i)) {
                    spot.classList.add("border-top");
                }

                lot.appendChild(spot);
            }
        }

        createParkingLot();
        updateStatus();
        
        function toggleParking(slot) {
            if (document.getElementById("modal").style.display === "block") return;
            showModal(slot);
        }
        window.addEventListener("resize", () => {
    const lot = document.getElementById("parkingLot");
    lot.innerHTML = "";
    createParkingLot();
    updateStatus();
});
    </script>
</body>
</html>

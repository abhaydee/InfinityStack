import React, { useState, useRef } from "react"
import { Card, CardProps } from 'antd';


export function CardGradient(props: CardProps) {
    return (
        <Card {...props} className={`${props.className} !backdrop-blur-sm !bg-[#1E1E1E]/30`}>
            {props.children}
        </Card>
    )
}
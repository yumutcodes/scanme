package com.backend.controller;

import com.backend.dto.request.PasswordUpdateRequest;
import com.backend.dto.request.UserPostRequest;
import com.backend.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping()
    public ResponseEntity<?> createUser(@RequestBody UserPostRequest userPostRequest) {
        userService.saveUser(userPostRequest);
        return ResponseEntity.ok("User created successfully!");
    }

    @PatchMapping("/users/{id}")
    public ResponseEntity<?> userPasswordChange(@PathVariable long id,
            @RequestBody PasswordUpdateRequest passwordUpdateRequest) {
        userService.changePassword(id, passwordUpdateRequest.getNewPassword());
        return ResponseEntity.noContent().build();
    }
}

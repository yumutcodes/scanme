package com.backend.controller;

import com.backend.dto.request.PasswordUpdateRequest;
import com.backend.dto.request.UserPostRequest;
import com.backend.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

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

    @GetMapping("/check/{email}")
    public ResponseEntity<?> checkUserExists(@PathVariable String email) {
        boolean exists = userService.userExistsByEmail(email);
        return ResponseEntity.ok(Map.of("exists", exists, "email", email));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<?> userPasswordChange(@PathVariable long id,
            @RequestBody PasswordUpdateRequest passwordUpdateRequest) {
        userService.changePassword(id, passwordUpdateRequest.getNewPassword());
        return ResponseEntity.noContent().build();
    }
}
